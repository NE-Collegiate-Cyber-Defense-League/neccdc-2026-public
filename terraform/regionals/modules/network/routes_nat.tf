# Branch public & corp private both don't have ipv4 addresses so cannot use the private nat gateway

resource "aws_route" "branch_private_nat" {
  route_table_id         = var.vpn_route_table_id
  destination_cidr_block = aws_subnet.branch_private.cidr_block
  nat_gateway_id         = var.private_nat_gateway_id
}


resource "aws_route" "corp_public_nat" {
  route_table_id         = var.vpn_route_table_id
  destination_cidr_block = aws_subnet.corp_public.cidr_block
  nat_gateway_id         = var.private_nat_gateway_id
}

resource "aws_route" "corp_dmz_nat" {
  route_table_id         = var.vpn_route_table_id
  destination_cidr_block = aws_subnet.corp_dmz.cidr_block
  nat_gateway_id         = var.private_nat_gateway_id
}
