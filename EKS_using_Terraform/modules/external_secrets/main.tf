resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
  }
}