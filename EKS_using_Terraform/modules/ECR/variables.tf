variable "cluster_name" {
  description = "Cluster name used as a prefix for repository names"
  type        = string
}

variable "repositories" {
  description = "Map of ECR repository configurations (e.g. frontend, backend, worker)"
  type = map(object({
    image_tag_mutability = string 
    scan_on_push         = bool
  }))
  default = {
    frontend = { image_tag_mutability = "MUTABLE", scan_on_push = true }
    backend  = { image_tag_mutability = "MUTABLE", scan_on_push = true }
    worker   = { image_tag_mutability = "MUTABLE", scan_on_push = true }
  }
}

variable "images_to_keep" {
  description = "Number of most recent images to retain per repository"
  type        = number
  default     = 10
}

variable "node_role_arn" {
  description = "IAM role ARN of EKS node group — granted pull access to ECR"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}