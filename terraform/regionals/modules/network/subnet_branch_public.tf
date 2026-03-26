resource "aws_subnet" "branch_public" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.region}a"

  ipv6_native                                    = true
  enable_dns64                                   = true
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  ipv6_cidr_block                                = var.cidrs.public_branch_ipv6

  tags = {
    Name    = "${var.team_number}-branch-public"
    network = "public"
    org     = "branch"
  }
}

resource "aws_network_acl_association" "branch_public" {
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.branch_public.id
}
