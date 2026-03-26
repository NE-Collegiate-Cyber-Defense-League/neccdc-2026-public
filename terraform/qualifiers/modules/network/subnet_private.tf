resource "aws_subnet" "private" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = local.private_ipv4_cidr

  enable_dns64                                   = true
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = var.second_ipv6_cidr

  tags = {
    Name    = "${var.team_number}-private"
    network = "private"
  }
}

resource "aws_network_acl_association" "private" {
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.private.id
}
