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


