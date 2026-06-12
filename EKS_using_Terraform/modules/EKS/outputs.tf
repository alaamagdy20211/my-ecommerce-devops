output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "oidc_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "oidc_url" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}