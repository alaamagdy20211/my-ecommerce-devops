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

