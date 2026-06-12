output "iam_role_arn" {
  value = aws_iam_role.external_secrets.arn
}

output "service_account" {
  value = var.service_account_name
}