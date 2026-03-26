resource "aws_security_group" "branch_pfSense_public" {
  name        = "${var.team_number}-pfSense-branch-public"
  description = "Allow ingress to pfSense only from WireGuard, black team NAT Gateway and corp pfSense"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.team_number}-pfSense-branch-public"
    network = "public"
    org     = "branch"
  }
}

resource "aws_vpc_security_group_ingress_rule" "branch_private_ipv4" {
  security_group_id = aws_security_group.branch_pfSense_public.id
  description       = "Team IPv4 address"
  cidr_ipv4         = var.cidrs.private_branch_ipv4
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "branch_ipv6" {
  for_each = toset([
    var.cidrs.public_branch_ipv6,
    var.cidrs.private_branch_ipv6,
    var.cidrs.public_corp_ipv6,
    var.cidrs.dmz_corp_ipv6,
    var.cidrs.private_corp_ipv6,
    var.vpn_subnet_ipv6_cidr
  ])

  security_group_id = aws_security_group.branch_pfSense_public.id
  description       = "Team IPv6 address"
  cidr_ipv6         = each.value
  ip_protocol       = "-1"
}


# Note: This rule does not actually do anything
resource "aws_vpc_security_group_egress_rule" "branch_egress_ipv4" {
  security_group_id = aws_security_group.branch_pfSense_public.id
  description       = "Allow all out"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "branch_egress_v6" {
  security_group_id = aws_security_group.branch_pfSense_public.id
  description       = "Allow all out"
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
