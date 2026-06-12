# variable "region" {
# type = string
# default = "us-east-1"
# }

# variable "vpc_id" {
# type = string
# }

# variable "subnet_ids" {
# type = list(string)
# }

# variable "eks_cluster_name" {
# type = string
# default = "eks-cluster"
# }
# variable "node_groups" {
# type = map(object({
#   instance_types    = list(string)
#   capacity_type     = string
#  scaling_config   = object({
#     desired_size = number
#     max_size     = number
#     min_size     = number
#   })
# }))
# }
# variable "cluster_version"  {
# type = string
# }
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for node groups and cluster"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}