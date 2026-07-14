# Using this file to generate the aws alb values for the argoCD application. This is to avoid hardcoding the values in the argoCD application and to make it dynamic based on the terraform variables.
resource "local_file" "aws_alb_values" {
  filename = "${path.module}/../argoCD/environments/dev/aws_alb_values.yaml"

  content = yamlencode({
    fullnameOverride = "aws-load-balancer-controller"
    clusterName      = aws_eks_cluster.eks_cluster.name
    vpcId            = aws_vpc.main.id

    replicaCount = 2

    serviceAccount = {
      name        = "aws-load-balancer-controller"
      annotations = {}
    }

    ingressClassConfig = {
      default = false
    }

    logLevel = "info"

    resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "500m"
        memory = "512Mi"
      }
    }

    podDisruptionBudget = {
      maxUnavailable = 1
    }
  })
}
