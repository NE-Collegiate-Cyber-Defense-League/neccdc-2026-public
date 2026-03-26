resource "aws_network_interface" "branch" {
  subnet_id         = aws_subnet.branch.id
  description       = "Branch interface for team ${var.team_number}"
  source_dest_check = false

  ipv6_addresses = [
    cidrhost(var.first_ipv6_cidr, -2) # 2600:1f26:1d:8cXX:ffff:ffff:ffff:fffe
  ]

  security_groups = [var.security_group]

  tags = {
    Name = "${var.team_number}-pfSense-branch"
  }
}


resource "aws_network_interface" "private" {
  subnet_id         = aws_subnet.private.id
  description       = "Private interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(local.private_ipv4_cidr, -2)] # 10.0.X.126

  ipv6_addresses = [
    cidrhost(var.second_ipv6_cidr, -2) # 2600:1f26:1d:8dXX:ffff:ffff:ffff:fffe
  ]

  security_groups = [var.security_group]

  tags = {
    Name = "${var.team_number}-pfSense-private"
  }
}


resource "aws_network_interface" "public" {
  subnet_id         = aws_subnet.public.id
  description       = "Public interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(local.public_ipv4_cidr, -2)] # 10.0.X.254

  ipv6_addresses = [
    cidrhost(var.third_ipv6_cidr, -2) # 2600:1f26:1d:8eXX:ffff:ffff:ffff:fffe
  ]

  security_groups = [aws_security_group.pfSense_public.id]

  tags = {
    Name = "${var.team_number}-pfSense-public"
  }
}

resource "aws_eip" "pfSense_public" {
  domain            = "vpc"
  network_interface = aws_network_interface.public.id

  tags = {
    Name = "${var.team_number}-pfSense-public"
  }
}


resource "aws_network_interface" "screened" {
  subnet_id         = aws_subnet.screened.id
  description       = "Screened subnet interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(local.screened_ipv4_cidr, -2)] # 10.0.X.190

  security_groups = [var.security_group]

  tags = {
    Name = "${var.team_number}-pfSense-screened"
  }
}
