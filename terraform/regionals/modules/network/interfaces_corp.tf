resource "aws_network_interface" "corp_private" {
  subnet_id         = aws_subnet.corp_private.id
  description       = "Private corp interface for team ${var.team_number}"
  source_dest_check = false

  ipv6_addresses = [
    cidrhost(var.cidrs.private_corp_ipv6, -2)
  ]

  security_groups = [var.security_group]

  tags = {
    Name    = "${var.team_number}-pfSense-corp-private"
    network = "private"
    org     = "corp"
  }
}


resource "aws_network_interface" "corp_public" {
  subnet_id         = aws_subnet.corp_public.id
  description       = "Public corp interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(var.cidrs.public_corp_ipv4, -2)]

  ipv6_addresses = [
    cidrhost(var.cidrs.public_corp_ipv6, -2)
  ]

  security_groups = [aws_security_group.corp_pfSense_public.id]

  tags = {
    Name    = "${var.team_number}-pfSense-corp-public"
    network = "public"
    org     = "corp"
  }
}

resource "aws_eip" "pfSense_corp_public" {
  domain            = "vpc"
  network_interface = aws_network_interface.corp_public.id

  tags = {
    Name    = "${var.team_number}-pfSense-corp-public"
    network = "public"
    org     = "corp"
  }
}


resource "aws_network_interface" "corp_dmz" {
  subnet_id         = aws_subnet.corp_dmz.id
  description       = "dmz corp subnet interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(var.cidrs.dmz_corp_ipv4, -2)]

  ipv6_addresses = [
    cidrhost(var.cidrs.dmz_corp_ipv6, -2)
  ]

  security_groups = [var.security_group]

  tags = {
    Name    = "${var.team_number}-pfSense-corp-dmz"
    network = "dmz"
    org     = "corp"
  }
}
