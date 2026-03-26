resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.this.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = data.aws_internet_gateway.this.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.corp_dmz.ipv6_cidr_block
    network_interface_id = aws_network_interface.corp_public.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.corp_private.ipv6_cidr_block
    network_interface_id = aws_network_interface.corp_public.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.branch_private.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch_public.id
  }

  route {
    cidr_block = var.remote_ipsec_cidr
    gateway_id = var.ipsec_virtual_gateway
  }

  tags = {
    Name    = "${var.team_number}-public"
    network = "public"
  }
}
