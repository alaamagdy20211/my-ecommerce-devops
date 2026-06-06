output "addon_status" {
  value = aws_eks_addon.ebs_csi.status
}

output "iam_role_arn" {
  value = aws_iam_role.ebs_csi.arn
}