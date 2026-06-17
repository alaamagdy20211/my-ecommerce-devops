variable "namespace" {
  type    = string
  default = "efs_csi_driver"
}

variable "service_account_name" {
  type    = string
  default = "efs_csi_driver_sa"
}

variable "irsa_role_arn" {
  description = "IAM role ARN (IRSA) for the External Secrets service account"
  type        = string
}

variable "helm_chart_version" {
  description = "Version of the external-secrets Helm chart"
  type        = string
  default     = "0.9.13"
}
