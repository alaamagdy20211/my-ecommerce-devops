resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role = aws_iam_role.ebs_csi.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = var.cluster_name

  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.addon_version

  service_account_role_arn = aws_iam_role.ebs_csi.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi
  ]
}


resource "kubernetes_storage_class" "ebs" {
  metadata {
    name = var.storage_class_name
  }

  storage_provisioner = "ebs.csi.aws.com"

  volume_binding_mode = var.volume_binding_mode

  parameters = {
    type = var.ebs_type
  }

  depends_on = [
    aws_eks_addon.ebs_csi
  ]
}

