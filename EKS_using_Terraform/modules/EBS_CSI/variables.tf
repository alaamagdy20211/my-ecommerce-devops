variable "cluster_name" {
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