terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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

# NOTE: The "kubernetes" provider and its data sources have been removed.
# Nothing in this configuration creates "kubernetes_*" resources directly —
# the ALB controller and External Secrets are both installed via "helm_release",
# which only opens a connection to the cluster at the point Terraform actually
# reconciles that specific resource (lazy connect). By that point module.eks
# has already been created in the same apply, so its outputs are concrete.
#
# The "kubernetes" provider, by contrast, must resolve its connection details
# (host/cluster_ca_certificate/token) before Terraform can even build the plan
# for any "kubernetes_*" resource. Since we don't have any such resources,
# keeping that provider around only reintroduces the chicken-and-egg problem
# for no benefit — so it's gone.
#
# The "helm" provider uses an "exec" block (same pattern as the AWS CLI uses
# for kubeconfig) so the actual "aws eks get-token" call is deferred to
# apply-time of each helm_release, not provider-init time. This means a
# single "terraform apply" from a clean state works correctly — no need for
# a two-step "-target=module.eks" apply.

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
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
# Each controller gets its own dedicated IRSA role + namespace + service
# account. Sharing a single SA across the ALB controller, EBS CSI, and
# External Secrets would mean the trust policy's "sub" condition only
# matches one of them.

module "alb_irsa" {
  source = "./modules/IRSA"

  name              = "alb-controller"
  oidc_provider_arn = module.eks.oidc_arn
  oidc_issuer       = replace(module.eks.oidc_url, "https://", "")
  namespace         = "kube-system"
  service_account   = "aws-load-balancer-controller"
  policy_arn        = module.iam_policy.alb_policy_arn
}

module "ebs_csi_irsa" {
  source = "./modules/IRSA"

  name              = "ebs-csi"
  oidc_provider_arn = module.eks.oidc_arn
  oidc_issuer       = replace(module.eks.oidc_url, "https://", "")
  namespace         = "kube-system"
  service_account   = "ebs-csi-controller-sa"
  policy_arn        = module.iam_policy.ebs_csi_policy_arn
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

  region                = var.region
  cluster_name          = module.eks.cluster_name
  vpc_id                = module.vpc.vpc_id
  irsa_role_arn         = module.alb_irsa.role_arn
  service_account_name  = "aws-load-balancer-controller"

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

  # The ALB controller's mutating webhook ("mservice.elbv2.k8s.aws") intercepts
  # every Service object cluster-wide, not just its own. If External Secrets'
  # chart creates its Service while the ALB controller's webhook is registered
  # but its pods aren't Ready yet, the API server blocks waiting for endpoints
  # that don't exist, producing "no endpoints available for service
  # aws-load-balancer-webhook-service". Sequencing after alb_controller (which
  # has wait/atomic = true, so it only "completes" once its pods are actually
  # Ready) removes that race.
  depends_on = [module.eks, module.secret_manager_irsa, module.alb_controller]
}


module "ecr" {
  source = "./modules/ECR"

  cluster_name   = var.cluster_name
  node_role_arn  = module.eks.node_role_arn
  images_to_keep = 10
  repositories   = var.repositories
}