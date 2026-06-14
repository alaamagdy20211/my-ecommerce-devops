variable "region" {
  default = "us-east-1"
}

variable "name" {}

variable "cluster_name" {}
variable "cluster_version" {}

variable "vpc_cidr" {}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "node_groups" {
  type = map(object({
    desired        = number
    max            = number
    min            = number
    instance_types = list(string)
  }))
}

variable "tags" {
  type = map(string)
}


variable "repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)

  default = [
    "frontend",
    "backend"
  ]
}