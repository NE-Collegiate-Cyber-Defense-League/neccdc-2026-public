resource "aws_vpc_ipam_pool" "ipv6_first_public" {
  address_family = "ipv6"
  ipam_scope_id  = aws_vpc_ipam.main.public_default_scope_id
  locale         = var.region
  description    = "Public IPv6 pool"

  public_ip_source = "amazon"
  aws_service      = "ec2"
}

resource "aws_vpc_ipam_pool_cidr" "ipv6_first_public" {
  ipam_pool_id   = aws_vpc_ipam_pool.ipv6_first_public.id
  netmask_length = 52
}
