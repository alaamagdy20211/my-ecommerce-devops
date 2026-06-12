resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = var.namespace

  create_namespace = true

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = var.service_account_name
      }
    })
  ]

}