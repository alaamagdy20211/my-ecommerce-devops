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

# FIX: The kubernetes and helm providers CANNOT reference module outputs directly.
# At provider init time, module.eks does not exist yet, which causes a
# chicken-and-egg error. The correct fix is to use data sources that are
# evaluated AFTER the EKS cluster exists (Terraform resolves data sources
# during the apply graph walk, not at init time, so this works correctly).
#
# IMPORTANT: Run `terraform apply -target=module.eks` on first deploy,
# then `terraform apply` for everything else. This is the standard pattern
# for EKS + Helm/Kubernetes providers in a single root module.

data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", "eks-cluster", "--region", "us-east-1"]
    }
  }
}


module "vpc" {
  source = "./modules/VPC"

  name            = var.name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
  tags            = var.tags
}


module "eks" {
  source = "./modules/EKS"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  private_subnets = module.vpc.private_subnets
  node_groups     = var.node_groups
  tags            = var.tags
}


module "iam_policy" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

# ── IRSA Roles ───────────────────────────────────────────────────────────────

# FIX: Each controller must use its OWN dedicated namespace and service account.
# Sharing a single SA across ALB controller, EBS CSI, and External Secrets
# means the IRSA trust policy only works for ONE of them — the one whose
# "sub" claim matches. Each gets its own role with the correct SA binding.

module "alb_irsa" {
  source = "./modules/IRSA"

  name              = "alb-controller"
  oidc_provider_arn = module.eks.oidc_arn
  # FIX: oidc_issuer must strip the https:// prefix for the condition variable key
  oidc_issuer     = replace(module.eks.oidc_url, "https://", "")
  namespace       = "kube-system"
  # FIX: service_account must match exactly what the Helm chart creates/uses.
  # The ALB controller Helm chart default SA name is "aws-load-balancer-controller".
  service_account = "aws-load-balancer-controller"
  policy_arn      = module.iam_policy.alb_policy_arn
}

module "ebs_csi_irsa" {
  source = "./modules/IRSA"

  name              = "ebs-csi"
  oidc_provider_arn = module.eks.oidc_arn
  oidc_issuer       = replace(module.eks.oidc_url, "https://", "")
  # FIX: EBS CSI driver addon uses the "kube-system" namespace
  # and "ebs-csi-controller-sa" service account by convention.
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  policy_arn      = module.iam_policy.ebs_csi_policy_arn
}

module "secret_manager_irsa" {
  source = "./modules/IRSA"

  name              = "external-secrets"
  oidc_provider_arn = module.eks.oidc_arn
  oidc_issuer       = replace(module.eks.oidc_url, "https://", "")
  # FIX: External Secrets Operator uses its own namespace and SA.
  # These must match the values passed to the Helm chart below.
  namespace       = "external-secrets"
  service_account = "external-secrets-sa"
  policy_arn      = module.iam_policy.secretsmanager_policy_arn
}


module "alb_controller" {
  source = "./modules/ALB_ingress"

  region             = var.region
  cluster_name       = module.eks.cluster_name
  vpc_id             = module.vpc.vpc_id
  # FIX: Pass the IRSA role ARN so the Helm chart can annotate the SA.
  irsa_role_arn      = module.alb_irsa.role_arn
  # FIX: SA name must match what the IRSA trust policy was created for.
  service_account_name = "aws-load-balancer-controller"

  depends_on = [module.eks, module.alb_irsa]
}


module "ebs_csi" {
  source = "./modules/EBS_CSI"

  cluster_name  = module.eks.cluster_name
  addon_version = "v1.44.0-eksbuild.1"
  irsa_role_arn = module.ebs_csi_irsa.role_arn

  depends_on = [module.eks, module.ebs_csi_irsa]
}


module "secret-manager" {
  source = "./modules/external_secrets"

  namespace            = "external-secrets"
  service_account_name = "external-secrets-sa"
  irsa_role_arn        = module.secret_manager_irsa.role_arn

  depends_on = [module.eks, module.secret_manager_irsa]
}


module "ecr" {
  source = "./modules/ECR"

  cluster_name   = var.cluster_name
  node_role_arn  = module.eks.node_role_arn
  images_to_keep = 10
}