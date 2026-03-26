resource "aws_network_acl" "this" {
  vpc_id = var.vpc_id

  ingress {
    protocol   = "-1"
    rule_no    = 10
    action     = "allow"
    cidr_block = var.cidrs.public_corp_ipv4
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 11
    action          = "allow"
    ipv6_cidr_block = var.cidrs.public_corp_ipv6
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 20
    action     = "allow"
    cidr_block = var.cidrs.dmz_corp_ipv4
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 21
    action          = "allow"
    ipv6_cidr_block = var.cidrs.dmz_corp_ipv6
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 30
    action          = "allow"
    ipv6_cidr_block = var.cidrs.private_corp_ipv6
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 40
    action          = "allow"
    ipv6_cidr_block = var.cidrs.public_branch_ipv6
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 50
    action     = "allow"
    cidr_block = var.cidrs.private_branch_ipv4
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 51
    action          = "allow"
    ipv6_cidr_block = var.cidrs.private_branch_ipv6
    from_port       = 0
    to_port         = 0
  }

  # Private NAT Subnet
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.255.255.0/24"
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

  # Ipsec team
  ingress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.remote_ipsec_team_cidr
    from_port  = 0
    to_port    = 0
  }

  # Ipsec staff
  ingress {
    protocol   = "-1"
    rule_no    = 201
    action     = "allow"
    cidr_block = var.remote_ipsec_staff
    from_port  = 0
    to_port    = 0
  }

  # Ipsec cidr
  ingress {
    protocol   = "-1"
    rule_no    = 210
    action     = "deny"
    cidr_block = var.remote_ipsec_cidr
    from_port  = 0
    to_port    = 0
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
    rule_no    = 501
    action     = "deny"
    cidr_block = "10.0.0.0/8"
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

  # Egress
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
