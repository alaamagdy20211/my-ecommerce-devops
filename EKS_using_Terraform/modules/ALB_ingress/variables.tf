variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID — passed to the Helm chart so the controller can discover subnets"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "helm_chart_version" {
  description = "Version of the aws-load-balancer-controller Helm chart"
  type        = string
  default     = "1.8.1"
}

variable "irsa_role_arn" {
  description = "IAM role ARN (IRSA) for the ALB controller service account"
  type        = string
}

variable "service_account_name" {
  description = "Service account name for the ALB controller (must match IRSA trust policy)"
  type        = string
  default     = "aws-load-balancer-controller"
}

