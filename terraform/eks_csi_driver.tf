resource "aws_iam_role" "eks_csi_role" {
  name = "${local.env}-${local.eks_name}-ebs-csi-driver"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.eks_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
/*
resource "aws_iam_policy" "ebs_csi_driver_encryption" {
  name = "${aws_eks_cluster.eks.name}-ebs-csi-driver-encryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })
}

# Optional: only if you want to encrypt the EBS drives
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption" {
  policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
  role       = aws_iam_role.ebs_csi_driver.name
}
*/

resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.eks_csi_role.arn
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.62.0-eksbuild.1"

  depends_on = [aws_eks_pod_identity_association.ebs_csi_driver]
}
