# variable "cluster_name" {
#   type = string
# }

# variable "oidc_provider_arn" {
#   type = string
# }

# variable "oidc_issuer_url" {
#   type = string
# }

# variable "addon_version" {
#   type = string
# }

# variable "storage_class_name" {
#   type    = string
#   default = "gp3"
# }

# variable "ebs_type" {
#   type    = string
#   default = "gp3"
# }

# variable "volume_binding_mode" {
#   type    = string
#   default = "WaitForFirstConsumer"
# }

# variable "environment" {
#   type = string
# }

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL (https://...) of the EKS cluster"
  type        = string
}

variable "addon_version" {
  description = "Version of the aws-ebs-csi-driver add-on"
  type        = string
}

variable "storage_class_name" {
  description = "Name for the Kubernetes StorageClass"
  type        = string
  default     = "gp3"
}

variable "ebs_type" {
  description = "EBS volume type (gp3 recommended)"
  type        = string
  default     = "gp3"
}

variable "volume_binding_mode" {
  description = "StorageClass volume binding mode"
  type        = string
  default     = "WaitForFirstConsumer"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}