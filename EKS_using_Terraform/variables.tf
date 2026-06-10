variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
variable "eks_cluster_name" {
  type = string
}


variable "node_groups" {
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

variable "cluster_version" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}
variable "ebs_csi_addon_version" {
  type = string
  
}

variable "storage_class_name" {
  type = string
  
}

variable "ebs_type" {
  type = string
  
}


variable "volume_binding_mode" {
  type = string
}

variable "environment" {
  type = string
}