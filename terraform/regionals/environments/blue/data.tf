data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["vpc"]
  }
  filter {
    name   = "tag:team"
    values = ["shared"]
  }
}


data "aws_route_table" "vpn" {
  tags = {
    Name    = "public-vpn"
    network = "public"
    team    = "shared"
  }
}


data "aws_nat_gateway" "private_nat" {
  state = "available"

  tags = {
    network = "private"
  }
}


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


data "aws_security_group" "team" {
  vpc_id = data.aws_vpc.this.id

  name = "blue-team"

  filter {
    name   = "tag:team"
    values = ["shared"]
  }
}


data "aws_vpn_gateway" "this" {
  attached_vpc_id = data.aws_vpc.this.id
  state           = "available"
}

data "aws_vpn_connection" "this" {
  filter {
    name   = "vpn-gateway-id"
    values = [data.aws_vpn_gateway.this.id]
  }
}
