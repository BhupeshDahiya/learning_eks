variable "app_repo_url" {
  description = "URL of the Java app GitHub repo"
  type        = string
}

variable "github_token" {
  description = "GitHub PAT for accessing the app repo"
  type        = string
  sensitive   = true
}

# Registers the app repo with ArgoCD
resource "kubernetes_secret" "argocd_repo" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "java-app-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.app_repo_url
    username = "git"
    password = var.github_token
  }
}

# ArgoCD Application for the Java app
resource "kubernetes_manifest" "java_app" {
  depends_on = [kubernetes_secret.argocd_repo]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "java-app"
      namespace = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
      annotations = {
        "argocd.argoproj.io/sync-wave" = "10"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.app_repo_url
        targetRevision = "HEAD"
        path           = "k8s" # path inside your app repo where manifests live
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune     = true
          selfHeal  = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}
