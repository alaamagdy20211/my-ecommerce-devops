variable "cluster_name" {}
variable "cluster_version" {}
variable "private_subnets" { type = list(string) }

variable "node_groups" {
  type = map(object({
    desired        = number
    max            = number
    min            = number
    instance_types = list(string)
  }))
}


variable "tags" {
  type    = map(string)
  default = {}
}
variable "vpc_id" {
  type = string
}