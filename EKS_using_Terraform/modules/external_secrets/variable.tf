variable "cluster_name" {
    type = string
}
variable "namespace" {
    type = string
  default = "external-secrets"
}
variable "service_account_name" {
    type = string
  default = "external-secrets-sa"
}
variable "aws_region" {
    type = string
}