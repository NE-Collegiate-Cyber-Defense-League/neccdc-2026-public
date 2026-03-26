resource "aws_network_acl" "this" {
  vpc_id = var.vpc_id

  ingress {
    protocol   = "-1"
    rule_no    = 10
    action     = "allow"
    cidr_block = var.ipv4_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 20
    action          = "allow"
    ipv6_cidr_block = var.first_ipv6_cidr
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 30
    action          = "allow"
    ipv6_cidr_block = var.second_ipv6_cidr
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 40
    action          = "allow"
    ipv6_cidr_block = var.third_ipv6_cidr
    from_port       = 0
    to_port         = 0
  }

  # Private NAT Subnet
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.255.0/24"
    from_port  = 0
    to_port    = 0
  }

  # VPN Subnet
  ingress {
    protocol        = "-1"
    rule_no         = 110
    action          = "allow"
    ipv6_cidr_block = var.vpn_subnet_ipv6_cidr
    from_port       = 0
    to_port         = 0
  }


  ingress {
    protocol        = "-1"
    rule_no         = 500
    action          = "deny"
    ipv6_cidr_block = var.global_ipv6_cidr
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 600
    action     = "deny"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 0
  }

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
    Name = "${var.team_number}-nacl"
  }
}
