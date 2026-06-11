output "cluster-endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
  
}
output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

# output "oidc_provider_arn" {
#   value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].arn
# }

output "oidc_issuer_url" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}