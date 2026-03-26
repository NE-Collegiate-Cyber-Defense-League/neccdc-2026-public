resource "aws_vpc" "this" {
  cidr_block = "10.255.0.0/16"

  ipv6_ipam_pool_id   = data.aws_vpc_ipam_pool.ipv6.id
  ipv6_netmask_length = split("/", local.global_ipv6_cidr)[1]

  tags = {
    Name = "vpc"
    team = "shared"
  }
}


resource "aws_vpc_ipv4_cidr_block_association" "corp_private" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.3.0.0/16"
}

resource "aws_vpc_ipv4_cidr_block_association" "corp_public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.7.0.0/16"
}

resource "aws_vpc_ipv4_cidr_block_association" "branch_private" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.100.0.0/16"
}


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw"
    team = "shared"
  }
}

resource "aws_route_table" "edge_associated" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "edge-associated"
    team = "shared"
  }
}

resource "aws_route_table_association" "igw_edge_associated" {
  route_table_id = aws_route_table.edge_associated.id
  gateway_id     = aws_internet_gateway.this.id
}


resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = {
    Name = "default"
  }
}

resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  tags = {
    Name = "default"
  }
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "default"
  }
}
