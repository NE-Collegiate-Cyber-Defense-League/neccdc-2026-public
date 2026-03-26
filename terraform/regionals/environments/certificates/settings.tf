terraform {
  required_version = "~> 1.13.0"

  backend "s3" {
    bucket = "neccdc-2026-terraform"
    key    = "regionals/certificates/terraform.tfstate"
    region = "us-east-2"

    profile = "neccdc"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.15.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.38.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  profile = "neccdc"

  default_tags {
    tags = {
      terraform = "true"
      path      = "terraform/regionals/environments/certificates"
    }
  }
}

provider "acme" {
  # Staging endpoint
  # server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"

  # Production endpoint
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
