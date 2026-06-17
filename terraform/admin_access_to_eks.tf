/*
resource "aws_iam_user" "eks_admin_acess_user" {
  name = "eks-admin-access"

  tags = {
    name = "${local.env}-${local.eks_name}-admin-user"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.eks_admin_access.arn]
  }
}

resource "aws_iam_policy" "assume_eks_admin_role" {
  name        = "assume-eks-admin-role"
  description = "Allows assuming the EKS Admin role"
  policy      = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_user_policy_attachment" "attach_assume_role" {
  user       = aws_iam_user.eks_admin_access_user.name # Fixed typo here too
  policy_arn = aws_iam_policy.assume_eks_admin_role.arn
}

# above can be used for a user
*/

resource "aws_iam_user" "eks_admin_user" {
  name = "eks-admin-user"
}

resource "aws_iam_group" "eks_admins" {
  name = "eks-admins"
}

# Add the User to the Group
resource "aws_iam_group_membership" "eks_team" {
  name = "eks-admin-group-membership"

  users = [
    aws_iam_user.eks_admin_user.name
    # You can easily add more users here in the future
  ]

  group = aws_iam_group.eks_admins.name
}

resource "aws_iam_policy" "assume_eks_admin_role" {
  name        = "assume-eks-admin-role"
  description = "Allows members to assume the EKS Admin role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = aws_iam_role.eks_admin_access.arn
    }]
  })
}

# Attach the Policy to the Group
resource "aws_iam_group_policy_attachment" "eks_admin_policy_attach" {
  group      = aws_iam_group.eks_admins.name
  policy_arn = aws_iam_policy.assume_eks_admin_role.arn
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_admin_access" {
  name = "eks_admin_access_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" # "arn:aws:iam::123456789012:role/PlatformEngineer" (for a iam role in your org)
          # To let users in a group assume a role, configure the Role's trust policy to trust the AWS Account itself. Then control who can actually execute that trust via the identity policy (using assume_eks_admin_role).
        }
      },
    ]
  })

  tags = {
    name = "${local.env}-${local.eks_name}-admin-role"
  }
}

resource "aws_iam_policy" "eks_admin_policy" {
  name = "EKS_admin_access_policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole","iam:GetRole","iam:ListRoles",
        ]
        Effect   = "Allow"
        Resource = [
          aws_iam_role.cluster.arn,
          aws_iam_role.node.arn,
        ]
      },
      { 
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "autoscaling:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
            "eks:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_access_role_attach" {
  role       = aws_iam_role.eks_admin_access.name
  policy_arn = aws_iam_policy.eks_admin_policy.arn
}

resource "aws_eks_access_entry" "eks_admin_access_entry" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  principal_arn     = aws_iam_role.eks_admin_access.arn
  kubernetes_groups = ["my-admin"]
  type              = "STANDARD"
}
