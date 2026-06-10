variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "addon_version" {
  type = string
}

variable "storage_class_name" {
  type    = string
  default = "gp3"
}

variable "ebs_type" {
  type    = string
  default = "gp3"
}

variable "volume_binding_mode" {
  type    = string
  default = "WaitForFirstConsumer"
}

variable "environment" {
  type = string
}