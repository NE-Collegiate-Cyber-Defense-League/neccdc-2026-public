resource "aws_subnet" "private_nat" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = "10.0.255.0/24"

  tags = {
    Name    = "private-nat"
    network = "private"
    team    = "shared"
  }
}

resource "aws_route_table" "private_nat" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "private-nat"
    network = "private"
    team    = "shared"
  }
}

resource "aws_route_table_association" "private_nat" {
  subnet_id      = aws_subnet.private_nat.id
  route_table_id = aws_route_table.private_nat.id
}

resource "aws_network_acl" "private_nat" {
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
    Name    = "private-nat"
    network = "private"
    team    = "shared"
  }
}

resource "aws_network_acl_association" "private_nat" {
  network_acl_id = aws_network_acl.private_nat.id
  subnet_id      = aws_subnet.private_nat.id
}

resource "aws_nat_gateway" "private" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private_nat.id
  private_ip        = "10.0.255.200"

  secondary_private_ip_addresses = ["10.0.255.100"]

  tags = {
    Name    = "Private NAT"
    network = "private"
  }
}
