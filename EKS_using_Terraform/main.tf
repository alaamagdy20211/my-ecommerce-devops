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
data "tls_certificate" "eks" {
  url = module.eks.oidc_issuer_url
}


resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  url = module.eks.oidc_issuer_url
}

module "ebs_csi" {
  source = "./modules/EBS_CSI"

  cluster_name       = module.eks.cluster_name
  oidc_provider_arn  = aws_iam_openid_connect_provider.eks.arn
  oidc_issuer_url    = module.eks.oidc_issuer_url
  addon_version      = var.ebs_csi_addon_version
  storage_class_name = var.storage_class_name
  ebs_type           = var.ebs_type
  volume_binding_mode = var.volume_binding_mode
  environment        = var.environment

}


module "external_secrets" {
  source = "../modules/external-secrets"
  cluster_name        = var.cluster_name
  namespace           = "external-secrets"
  service_account_name = "external-secrets-sa"
  aws_region          = var.aws_region
}

