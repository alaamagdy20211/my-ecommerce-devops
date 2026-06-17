resource "helm_release" "efs_csi" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
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


