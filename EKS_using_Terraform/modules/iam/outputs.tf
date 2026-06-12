output "alb_policy_arn" {
  value = aws_iam_policy.alb_controller.arn
}

output "secretsmanager_policy_arn" {
  value = aws_iam_policy.secrets_manager.arn
}


output "ebs_csi_policy_arn" {
  value = aws_iam_policy.ebs_csi.arn
}