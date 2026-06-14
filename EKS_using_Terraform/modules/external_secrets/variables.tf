variable "namespace" {
  type    = string
  default = "external-secrets"
}

variable "service_account_name" {
  type    = string
  default = "external-secrets-sa"
}

# FIX: Added — the IRSA role ARN must be annotated on the SA so ESO pods
# can call Secrets Manager via IRSA. Without this the pods get AccessDenied.
variable "irsa_role_arn" {
  description = "IAM role ARN (IRSA) for the External Secrets service account"
  type        = string
}

variable "helm_chart_version" {
  description = "Version of the external-secrets Helm chart"
  type        = string
  default     = "0.9.13"
}
