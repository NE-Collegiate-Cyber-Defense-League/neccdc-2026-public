resource "aws_customer_gateway" "this" {
  bgp_asn    = 65000
  ip_address = var.remote_ipsec_ip
  type       = "ipsec.1"

  tags = {
    Name = "mcc-customer-gateway"
  }
}

resource "aws_vpn_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "mcc-ipsec-vpn"
  }
}

resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "mcc-ipsec-vpn"
  }
}

resource "aws_vpn_connection_route" "mcc" {
  destination_cidr_block = var.remote_subnet_cidr
  vpn_connection_id      = aws_vpn_connection.this.id
}
