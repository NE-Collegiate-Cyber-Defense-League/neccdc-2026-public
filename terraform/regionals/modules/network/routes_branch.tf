resource "aws_route_table_association" "branch_public" {
  subnet_id      = aws_subnet.branch_public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "branch_private" {
  vpc_id = var.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.branch_private.id
  }

  route {
    ipv6_cidr_block      = "::/0"
    network_interface_id = aws_network_interface.branch_private.id
  }

  # Branch Ipv4
  route {
    cidr_block           = aws_subnet.branch_private.cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  # Branch IPv6
  route {
    ipv6_cidr_block      = aws_subnet.branch_private.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.branch_public.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  # Corp IPv4
  route {
    cidr_block           = aws_subnet.corp_dmz.cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  route {
    cidr_block           = aws_subnet.corp_public.cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  # Corp IPv6
  route {
    ipv6_cidr_block      = aws_subnet.corp_private.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.corp_public.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.corp_dmz.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch_private.id
  }

  route {
    cidr_block = var.remote_ipsec_cidr
    gateway_id = var.ipsec_virtual_gateway
  }

  tags = {
    Name    = "${var.team_number}-branch-private"
    network = "private"
    org     = "branch"
  }
}

resource "aws_route_table_association" "branch_private" {
  subnet_id      = aws_subnet.branch_private.id
  route_table_id = aws_route_table.branch_private.id
}
