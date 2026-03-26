locals {
  # Shared between black and blue branch subnets
  global_ipv6_cidr = [for cidr in data.aws_vpc_ipam_pool_cidrs.ipv6.ipam_pool_cidrs : cidr.cidr if cidr.state == "provisioned"][0]

  # Used for vpn subnet
  vpn_cidr_range = cidrsubnet(local.global_ipv6_cidr, 12, 0)
}
