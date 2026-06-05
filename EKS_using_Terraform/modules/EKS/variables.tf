variable "region" {
type = string
default = "us-east-1"
}

variable "vpc_id" {
type = string
}
variable "public_subnet_ids" {
type = list(string)
}
variable "private_subnet_ids" {
type = list(string)
}

variable "subnet_ids" {
type = list(string)
}

variable "eks_cluster_name" {
type = string
default = "eks-cluster"
}
variable "node_groups" {
type = map(object({
  instance_types    = list(string)
  capacity_type     = string
 scaling_config   = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
}))
}
variable "cluster_version"  {
type = string
}