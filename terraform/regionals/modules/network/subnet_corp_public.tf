resource "aws_subnet" "corp_public" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  cidr_block              = var.cidrs.public_corp_ipv4

  enable_dns64                                   = true
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = var.cidrs.public_corp_ipv6

  tags = {
    Name    = "${var.team_number}-corp-public"
    network = "public"
    org     = "corp"
  }
}

resource "aws_network_acl_association" "corp_public" {
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.corp_public.id
}
