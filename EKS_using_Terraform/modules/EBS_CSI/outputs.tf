# output "iam_role_arn" {
#   value = aws_iam_role.ebs_csi.arn
# }

# # output "addon_status" {
# #   value = aws_eks_addon.ebs_csi.
# # }

# output "storage_class_name" {
#   value = kubernetes_storage_class_v1.ebs.metadata[0].name
# }


output "iam_role_arn" {
  description = "IAM role ARN used by the EBS CSI controller"
  value       = aws_iam_role.ebs_csi.arn
}

output "storage_class_name" {
  description = "Name of the created StorageClass"
  value       = kubernetes_storage_class_v1.gp3.metadata[0].name
}