resource "aws_subnet" "public_vpn" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  cidr_block              = local.vpn_ipv4_cidr_range

  enable_dns64    = true
  ipv6_cidr_block = local.vpn_ipv6_cidr_range

  tags = {
    Name    = "public-vpn"
    network = "public"
    team    = "shared"
  }
}


resource "aws_route_table" "public_vpn" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "public-vpn"
    network = "public"
    team    = "shared"
  }
}

resource "aws_route" "public_vpn_ipv4_gateway" {
  route_table_id         = aws_route_table.public_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "public_vpn_ipv6_gateway" {
  route_table_id              = aws_route_table.public_vpn.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}


resource "aws_route_table_association" "public_vpn" {
  subnet_id      = aws_subnet.public_vpn.id
  route_table_id = aws_route_table.public_vpn.id
}


resource "aws_network_acl" "public_vpn" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol   = "-1"
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 1001
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol        = "-1"
    rule_no         = 1001
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  tags = {
    Name    = "public-vpn"
    network = "public"
    team    = "shared"
  }
}

resource "aws_network_acl_association" "public_vpn" {
  network_acl_id = aws_network_acl.public_vpn.id
  subnet_id      = aws_subnet.public_vpn.id
}
