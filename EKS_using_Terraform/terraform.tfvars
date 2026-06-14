region = "us-east-1"

name = "eks-platform"

cluster_name    = "eks-cluster"
cluster_version = "1.29"

vpc_cidr = "10.0.0.0/16"

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.10.0/24",
  "10.0.11.0/24"
]

azs = [
  "us-east-1a",
  "us-east-1b"
]

node_groups = {
  generalll = {
    desired        = 4
    max            = 4
    min            = 1
    instance_types = ["c7i-flex.large"]
  }
}

tags = {
  Environment = "dev"
  Project     = "eks-platform"
}