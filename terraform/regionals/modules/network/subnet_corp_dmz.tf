resource "aws_subnet" "corp_dmz" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = var.cidrs.dmz_corp_ipv4

  enable_dns64                                   = true
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = var.cidrs.dmz_corp_ipv6

  tags = {
    Name    = "${var.team_number}-corp-dmz"
    network = "dmz"
    org     = "corp"
  }
}

resource "aws_network_acl_association" "corp_dmz" {
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.corp_dmz.id
}
