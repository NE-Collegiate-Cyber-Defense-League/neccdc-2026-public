resource "aws_route" "branch" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.branch.ipv6_cidr_block
  network_interface_id        = aws_network_interface.public.id
}

resource "aws_route" "public" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.public.ipv6_cidr_block
  network_interface_id        = aws_network_interface.public.id
}

resource "aws_route" "private" {
  route_table_id              = data.aws_route_table.edge_associated.id
  destination_ipv6_cidr_block = aws_subnet.private.ipv6_cidr_block
  network_interface_id        = aws_network_interface.public.id
}
