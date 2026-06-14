variable "cluster_name" {
  type = string
}

variable "images_to_keep" {
  type    = number
  default = 10
}

variable "node_role_arn" {
  type = string
}
