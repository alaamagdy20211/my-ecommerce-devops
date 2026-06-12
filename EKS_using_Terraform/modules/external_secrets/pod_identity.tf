resource "aws_eks_addon" "pod_identity" {
  cluster_name = var.cluster_name
  addon_name   = "eks-pod-identity-agent"
}
resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.external_secrets.arn
}

# helm repo add external-secrets https://charts.external-secrets.io
# helm install external-secrets external-secrets/external-secrets \
#   -n external-secrets --create-namespace