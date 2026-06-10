output "cluster-endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
  
}
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_issuer_url" {
  value = aws_iam_openid_connect_provider.eks.url
}