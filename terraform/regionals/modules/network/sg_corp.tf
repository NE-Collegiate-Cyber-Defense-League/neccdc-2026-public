resource "aws_security_group" "corp_pfSense_public" {
  name        = "${var.team_number}-pfSense-corp-public"
  description = "Allow ingress to pfSense only from WireGuard, black team NAT Gateway and branch pfSense"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.team_number}-pfSense-corp-public"
    network = "public"
    org     = "corp"
  }
}


resource "aws_vpc_security_group_ingress_rule" "corp_private_nat_subnet" {
  security_group_id = aws_security_group.corp_pfSense_public.id
  description       = "Private NAT subnet ipv4 cidr"
  cidr_ipv4         = var.private_nat_ipv4_subnet_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "corp_ipv4" {
  for_each = toset([
    var.cidrs.public_corp_ipv4,
    var.cidrs.dmz_corp_ipv4,
    "172.31.0.0/16"
  ])

  security_group_id = aws_security_group.corp_pfSense_public.id
  description       = "Team IPv4 address"
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "corp_ipv6" {
  for_each = toset([
    var.cidrs.public_corp_ipv6,
    var.cidrs.dmz_corp_ipv6,
    var.cidrs.private_corp_ipv6,
    var.cidrs.public_branch_ipv6,
    var.cidrs.private_branch_ipv6,
    var.vpn_subnet_ipv6_cidr
  ])

  security_group_id = aws_security_group.corp_pfSense_public.id
  description       = "Team IPv6 address"
  cidr_ipv6         = each.value
  ip_protocol       = "-1"
}


resource "aws_vpc_security_group_ingress_rule" "corp_pfSense_public_ip" {
  security_group_id = aws_security_group.corp_pfSense_public.id
  description       = "Public pfSense IPv4 address"
  cidr_ipv4         = "${aws_eip.pfSense_corp_public.public_ip}/32"
  ip_protocol       = "-1"
}


resource "aws_vpc_security_group_egress_rule" "corp_egress_ipv4" {
  security_group_id = aws_security_group.corp_pfSense_public.id
  description       = "Allow all out"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "corp_egress_v6" {
  security_group_id = aws_security_group.corp_pfSense_public.id
  description       = "Allow all out"
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
