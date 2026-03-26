data "aws_vpc_ipam_pool" "ipv6" {
  region = var.region

  filter {
    name   = "description"
    values = ["Public IPv6 pool"]
  }

  filter {
    name   = "address-family"
    values = ["ipv6"]
  }
}

data "aws_vpc_ipam_pool_cidrs" "ipv6" {
  ipam_pool_id = data.aws_vpc_ipam_pool.ipv6.id
}


data "aws_route53_zone" "public" {
  name         = "chefops.tech."
  private_zone = false
}


data "aws_ami" "ec2" {
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-0689a3ce09bf1872e"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

data "aws_ami" "ec2_x86" {
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-08e7c4ff68822709e"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
