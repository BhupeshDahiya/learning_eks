variable "app_repo_url" {
  description = "URL of the Java app GitHub repo"
  type        = string
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
    type = "git"
    url  = var.app_repo_url
  }
}
