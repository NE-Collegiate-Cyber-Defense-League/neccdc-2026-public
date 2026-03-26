locals {
  # Shared between black and blue branch subnets
  global_ipv6_cidr = [for cidr in data.aws_vpc_ipam_pool_cidrs.ipv6.ipam_pool_cidrs : cidr.cidr if cidr.state == "provisioned"][0]

  vpn_ipv4_cidr_range = cidrsubnet(aws_vpc.this.cidr_block, 8, 254) # 10.255.254.0/24
  vpn_ipv6_cidr_range = cidrsubnet(local.global_ipv6_cidr, 12, 0)   # 2600:1f26:1d:8000::/64

  nat_ipv4_cidr_range = cidrsubnet(aws_vpc.this.cidr_block, 8, 255) # 10.255.255.0/24
}
