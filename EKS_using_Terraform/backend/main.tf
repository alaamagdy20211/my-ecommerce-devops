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
        bucket= "alaa3008-terraform-state-2026"
        key= "env/terraform_state-file"
        region= "us-east-1"
        use_lockfile = true
        encrypt = true
    }
}