# output "cluster-endpoint" {
#   value = aws_eks_cluster.eks_cluster.endpoint
  
# }
# output "cluster_name" {
#   value = aws_eks_cluster.eks_cluster.name
# }

# # output "oidc_provider_arn" {
# #   value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].arn
# # }

# output "oidc_issuer_url" {
#   value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA certificate of the EKS cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider (used for IRSA)"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "node_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = aws_iam_role.node_group.arn
}