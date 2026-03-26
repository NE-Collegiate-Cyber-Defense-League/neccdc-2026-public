locals {
  team_number = terraform.workspace

  global_public_corp_ipv4    = "10.7.0.0/16"
  global_private_corp_ipv4   = "10.3.0.0/16"
  global_private_branch_ipv4 = "10.100.0.0/16"

  private_nat_subnet_cidr = "10.255.255.0/24"

  public_corp_ipv4    = cidrsubnet(local.global_public_corp_ipv4, 8, local.team_number)    # 10.7.X.0/24
  dmz_corp_ipv4       = cidrsubnet(local.global_private_corp_ipv4, 8, local.team_number)   # 10.3.X.0/24
  private_branch_ipv4 = cidrsubnet(local.global_private_branch_ipv4, 8, local.team_number) # 10.100.X.0/24

  # IPv6 Math
  global_ipv6_cidr = [for cidr in data.aws_vpc_ipam_pool_cidrs.ipv6.ipam_pool_cidrs : cidr.cidr if cidr.state == "provisioned"][0]

  vpn_subnet_ipv6_cidr = cidrsubnet(local.global_ipv6_cidr, 12, 0) # 8000::/64

  global_corp_ipv6   = cidrsubnet(local.global_ipv6_cidr, 4, 10) # 8a00::/56
  global_branch_ipv6 = cidrsubnet(local.global_ipv6_cidr, 4, 11) # 8b00::/56


  team_hex_offset = local.team_number * 16

  public_corp_ipv6    = cidrsubnet(local.global_corp_ipv6, 8, local.team_hex_offset)       # 8aX0::/64
  dmz_corp_ipv6       = cidrsubnet(local.global_corp_ipv6, 8, local.team_hex_offset + 1)   # 8aX1::/64
  private_corp_ipv6   = cidrsubnet(local.global_corp_ipv6, 8, local.team_hex_offset + 2)   # 8aX2::/64
  public_branch_ipv6  = cidrsubnet(local.global_branch_ipv6, 8, local.team_hex_offset)     # 8bX0::/64
  private_branch_ipv6 = cidrsubnet(local.global_branch_ipv6, 8, local.team_hex_offset + 1) # 8bX1::/64

  # Maps Team ID to MCC room number
  team_number_to_octet = {
    0  = 0
    1  = 209
    2  = 103
    3  = 112
    4  = 101
    5  = 114
    6  = 105
    7  = 212
    8  = 207
    9  = 109
    10 = 107
  }

  remote_ipsec_team_cidr = cidrsubnet(data.aws_vpn_connection.this.routes[0].destination_cidr_block, 8, local.team_number_to_octet[local.team_number]) # 172.31.X.0/24
  remote_ipsec_staff     = cidrsubnet(data.aws_vpn_connection.this.routes[0].destination_cidr_block, 8, 20)                                            # 172.31.20.0/24
}
