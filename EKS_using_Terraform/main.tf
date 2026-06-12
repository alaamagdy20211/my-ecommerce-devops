terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket       = "alaa3008-terraform-state-2026"
    key          = "env/terraform_state-file"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
    depends_on = [module.eks]

}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
    depends_on = [module.eks]

}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
module "vpc" {
  source = "./modules/VPC"

  name             = var.name
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  azs              = var.azs

  tags = var.tags
}

module "eks" {
  source = "./modules/EKS"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  private_subnets = module.vpc.private_subnets

  node_groups = var.node_groups
}

module "iam_policy" {
  source = "./modules/iam"
  cluster_name = var.cluster_name
}
module "alb_irsa" {
  source = "./modules/IRSA"
  name                = "alb-controller"
  oidc_provider_arn   = module.eks.oidc_arn
  oidc_issuer         = replace(module.eks.oidc_url, "https://", "")
  namespace           = "kube-system"
  service_account     = "aws-load-balancer-controller"
  policy_arn = module.iam_policy.alb_policy_arn
}
module "ebs_csi_irsa" {
  source = "./modules/IRSA"
  name              = "ebs-csi"
  oidc_provider_arn = module.eks.oidc_arn
  oidc_issuer       = replace(module.eks.oidc_url, "https://", "")
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  policy_arn = module.iam_policy.ebs_csi_policy_arn
}

module "secret_manager_irsa" {
  source = "./modules/IRSA"
  name              = "external-secrets"
  oidc_provider_arn = module.eks.oidc_arn
  oidc_issuer       = replace(module.eks.oidc_url, "https://", "")
  namespace         = "external-secrets"
  service_account   = "external-secrets-sa"
  policy_arn        = module.iam_policy.secretsmanager_policy_arn
}
module "alb_controller" {
  source = "./modules/ALB_ingress"
  region= var.region
  cluster_name  = module.eks.cluster_name
  vpc_id         = module.vpc.vpc_id
}

module "ebs_csi" {
  source = "./modules/EBS_CSI"

  cluster_name = module.eks.cluster_name

  addon_version = "v1.44.0-eksbuild.1"

  irsa_role_arn = module.ebs_csi_irsa.role_arn

}


module "secret-manager" {
  source = "./modules/external_secrets"
  namespace = "external-secrets"
  service_account_name ="external-secrets-sa"
}


module "ecr" {
  source = "./modules/ECR"
  cluster_name   = var.cluster_name
  node_role_arn  = module.eks.node_role_arn
  images_to_keep = 10
}