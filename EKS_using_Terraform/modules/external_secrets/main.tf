
resource "aws_secretsmanager_secret" "db_secret" {
  name = "ecommerce-db-secret"
   recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = file("${path.module}/db-secret.json")
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = var.namespace
  version    = var.helm_chart_version

  create_namespace = true

  atomic = true
  wait   = true
  timeout = 600

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = var.service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = var.irsa_role_arn
        }
      }
    })
  ]

  
}