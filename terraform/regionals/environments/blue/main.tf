module "network" {
  source = "../../modules/network"

  cidrs = {
    public_corp_ipv4    = local.public_corp_ipv4
    dmz_corp_ipv4       = local.dmz_corp_ipv4
    private_branch_ipv4 = local.private_branch_ipv4
    public_corp_ipv6    = local.public_corp_ipv6
    dmz_corp_ipv6       = local.dmz_corp_ipv6
    private_corp_ipv6   = local.private_corp_ipv6
    public_branch_ipv6  = local.public_branch_ipv6
    private_branch_ipv6 = local.private_branch_ipv6
  }

  global_ipv6_cidr = local.global_ipv6_cidr

  vpc_id      = data.aws_vpc.this.id
  region      = var.region
  team_number = local.team_number

  vpn_route_table_id = data.aws_route_table.vpn.id

  vpn_subnet_ipv6_cidr         = local.vpn_subnet_ipv6_cidr
  private_nat_gateway_id       = data.aws_nat_gateway.private_nat.id
  private_nat_ipv4_subnet_cidr = local.private_nat_subnet_cidr

  ipsec_virtual_gateway  = data.aws_vpn_gateway.this.id
  remote_ipsec_cidr      = data.aws_vpn_connection.this.routes[0].destination_cidr_block
  remote_ipsec_team_cidr = local.remote_ipsec_team_cidr
  remote_ipsec_staff     = local.remote_ipsec_staff

  security_group = data.aws_security_group.team.id
}


module "dns" {
  source = "../../modules/dns"

  team_number = local.team_number

  corp_pfSense_ips   = module.network.corp_pfSense_ips
  branch_pfSense_ips = module.network.branch_pfSense_ips
}


module "instances" {
  source = "../../modules/instances"

  team_number = local.team_number

  subnet_ids        = module.network.subnet_ids
  security_group_id = data.aws_security_group.team.id

  branch_pfSense_interfaces = module.network.branch_pfSense_interfaces
  corp_pfSense_interfaces   = module.network.corp_pfSense_interfaces

  cidrs = {
    public_corp_ipv4    = local.public_corp_ipv4
    dmz_corp_ipv4       = local.dmz_corp_ipv4
    private_branch_ipv4 = local.private_branch_ipv4
    public_corp_ipv6    = local.public_corp_ipv6
    dmz_corp_ipv6       = local.dmz_corp_ipv6
    private_corp_ipv6   = local.private_corp_ipv6
    public_branch_ipv6  = local.public_branch_ipv6
    private_branch_ipv6 = local.private_branch_ipv6
  }
}
