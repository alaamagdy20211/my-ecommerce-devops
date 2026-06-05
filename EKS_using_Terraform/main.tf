terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "terraform_state"{
    bucket = "alaa3008-terraform-state-2026"
    lifecycle {
        prevent_destroy=false
    }

}

terraform {
  backend "s3" {
    bucket       = "alaa3008-terraform-state-2026"
    key          = "env/terraform_state-file"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

module "vpc" {
  source               = "./modules/VPC"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  eks_cluster_name     = var.eks_cluster_name
  region               = var.region
}

module "eks" {
  source           = "./modules/EKS"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  eks_cluster_name = var.eks_cluster_name
  node_groups      = var.node_groups
  cluster_version  = var.cluster_version
  region           = var.region
}