vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24",

]

private_subnet_cidrs = [
  "10.0.4.0/24",
  "10.0.5.0/24",
  "10.0.6.0/24",
]

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]
eks_cluster_name = "eks-cluster-1"

cluster_version = "1.35"

node_groups = {
  node_group_1 = {
    instance_types = ["t3.micro"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 3
      max_size     = 4
      min_size     = 2
    }
  }
}

ebs_csi_addon_version = "v1.61.1-eksbuild.1"
storage_class_name = "gp3"
ebs_type = "gp3"
volume_binding_mode = "WaitForFirstConsumer"
environment = "dev"

