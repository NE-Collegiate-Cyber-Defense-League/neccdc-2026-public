locals {
  team_number = terraform.workspace

  global_ipv4_cidr = "10.0.0.0/16"
  global_ipv6_cidr = [for cidr in data.aws_vpc_ipam_pool_cidrs.ipv6.ipam_pool_cidrs : cidr.cidr if cidr.state == "provisioned"][0]

  vpn_subnet_ipv6_cidr = cidrsubnet(local.global_ipv6_cidr, 12, 0)

  # Break down global range into three general subnets
  first_ipv6_range  = cidrsubnet(local.global_ipv6_cidr, 4, 10) # a
  second_ipv6_range = cidrsubnet(local.global_ipv6_cidr, 4, 11) # b
  third_ipv6_range  = cidrsubnet(local.global_ipv6_cidr, 4, 12) # c

  # Get teams range subnet
  first_team_ipv6_subnet  = cidrsubnet(local.first_ipv6_range, 8, local.team_number)
  second_team_ipv6_subnet = cidrsubnet(local.second_ipv6_range, 8, local.team_number)
  third_team_ipv6_subnet  = cidrsubnet(local.third_ipv6_range, 8, local.team_number)

  team_ipv4_subnet = cidrsubnet(local.global_ipv4_cidr, 8, local.team_number)
}
