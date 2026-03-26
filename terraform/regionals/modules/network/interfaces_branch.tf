resource "aws_network_interface" "branch_private" {
  subnet_id         = aws_subnet.branch_private.id
  description       = "Private branch interface for team ${var.team_number}"
  source_dest_check = false

  private_ips = [cidrhost(var.cidrs.private_branch_ipv4, -2)]

  ipv6_addresses = [
    cidrhost(var.cidrs.private_branch_ipv6, -2)
  ]

  security_groups = [var.security_group]

  tags = {
    Name    = "${var.team_number}-pfSense-branch-private"
    network = "private"
    org     = "branch"
  }
}


resource "aws_network_interface" "branch_public" {
  subnet_id         = aws_subnet.branch_public.id
  description       = "Public branch interface for team ${var.team_number}"
  source_dest_check = false

  ipv6_addresses = [
    cidrhost(var.cidrs.public_branch_ipv6, -2)
  ]

  security_groups = [aws_security_group.branch_pfSense_public.id]

  tags = {
    Name    = "${var.team_number}-pfSense-branch-public"
    network = "public"
    org     = "branch"
  }
}
