terraform {
  required_version = "~> 1.13.2"

  backend "s3" {
    bucket = "neccdc-2026-terraform"
    key    = "regionals/blue/terraform.tfstate"
    region = "us-east-2"

    profile = "neccdc"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.35.1"
    }
  }
}

provider "aws" {
  region = var.region

  profile = "neccdc"

  default_tags {
    tags = {
      terraform = "true"
      path      = "terraform/regionals/environments/blue"
      team      = terraform.workspace
    }
  }
}
