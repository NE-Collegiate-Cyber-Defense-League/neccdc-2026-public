terraform {
  required_version = "~> 1.13.0"

  backend "s3" {
    bucket = "neccdc-2026-terraform"
    key    = "qualifiers/domain-redirect/terraform.tfstate"
    region = "us-east-2"

    profile = "neccdc"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.15.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  profile = "neccdc"

  default_tags {
    tags = {
      terraform = "true"
      path      = "terraform/qualifiers/environments/domain-redirect"
    }
  }
}
