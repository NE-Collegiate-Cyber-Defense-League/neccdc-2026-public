resource "aws_route" "edge_branch_private" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.branch_private.ipv6_cidr_block
  network_interface_id        = aws_network_interface.branch_public.id
}

resource "aws_route" "edge_branch_public" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.branch_public.ipv6_cidr_block
  network_interface_id        = aws_network_interface.branch_public.id
}


resource "aws_route" "edge_corp_private" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.corp_private.ipv6_cidr_block
  network_interface_id        = aws_network_interface.corp_public.id
}

resource "aws_route" "edge_corp_public" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.corp_public.ipv6_cidr_block
  network_interface_id        = aws_network_interface.corp_public.id
}

resource "aws_route" "edge_corp_dmz" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.corp_dmz.ipv6_cidr_block
  network_interface_id        = aws_network_interface.corp_public.id
}
