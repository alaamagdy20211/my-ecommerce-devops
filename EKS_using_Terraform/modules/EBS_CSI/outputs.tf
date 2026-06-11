output "iam_role_arn" {
  value = aws_iam_role.ebs_csi.arn
}

# output "addon_status" {
#   value = aws_eks_addon.ebs_csi.
# }

output "storage_class_name" {
  value = kubernetes_storage_class_v1.ebs.metadata[0].name
}