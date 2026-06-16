resource "aws_eks_cluster" "eks_cluster" {
  name = "${local.env}-${local.eks_name}"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true # let terrafrom user who created this eks have admin access
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "${local.eks_version}"

  vpc_config {
    endpoint_private_access = false # Resources inside VPC will reach the API server through the public endpoint
    endpoint_public_access  = true  # enables a publicly accessible Kubernetes API endpoint

    subnet_ids = [
      aws_subnet.pvt_1.id,
      aws_subnet.pvt_2.id
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "cluster" {
  name = "${local.env}-${local.eks_name}-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}