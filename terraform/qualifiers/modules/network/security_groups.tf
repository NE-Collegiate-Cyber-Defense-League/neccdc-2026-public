resource "aws_security_group" "pfSense_public" {
  name        = "${var.team_number}-pfSense-Public"
  description = "Allow ingress to pfSense only from WireGuard, black team NAT Gateway and other IPs"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.team_number}-pfSense-Public"
  }
}


resource "aws_vpc_security_group_ingress_rule" "private_nat_subnet" {
  security_group_id = aws_security_group.pfSense_public.id
  description       = "Private NAT subnet ipv4 cidr"
  cidr_ipv4         = var.private_nat_ipv4_subnet_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "team_ipv4" {
  for_each = toset([
    local.private_ipv4_cidr,
    local.screened_ipv4_cidr,
    local.public_ipv4_cidr,
    local.branch_ipv4_cidr
  ])

  security_group_id = aws_security_group.pfSense_public.id
  description       = "Team IPv4 address"
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "team_ipv6" {
  for_each = toset([
    var.first_ipv6_cidr,
    var.second_ipv6_cidr,
    var.third_ipv6_cidr,
    var.vpn_subnet_ipv6_cidr
  ])

  security_group_id = aws_security_group.pfSense_public.id
  description       = "Team IPv6 address"
  cidr_ipv6         = each.value
  ip_protocol       = "-1"
}


resource "aws_vpc_security_group_ingress_rule" "pfSense_public_ip" {
  security_group_id = aws_security_group.pfSense_public.id
  description       = "Public pfSense IPv4 address"
  cidr_ipv4         = "${aws_eip.pfSense_public.public_ip}/32"
  ip_protocol       = "-1"
}


resource "aws_vpc_security_group_egress_rule" "all_egress" {
  security_group_id = aws_security_group.pfSense_public.id
  description       = "Allow all out"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_egress_v6" {
  security_group_id = aws_security_group.pfSense_public.id
  description       = "Allow all out"
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
