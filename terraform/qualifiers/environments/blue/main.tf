module "network" {
  source = "../../modules/network"

  first_ipv6_cidr  = local.first_team_ipv6_subnet
  second_ipv6_cidr = local.second_team_ipv6_subnet
  third_ipv6_cidr  = local.third_team_ipv6_subnet
  ipv4_cidr        = local.team_ipv4_subnet

  global_ipv6_cidr = local.global_ipv6_cidr

  vpc_id      = data.aws_vpc.this.id
  region      = var.region
  team_number = local.team_number

  vpn_route_table_id = data.aws_route_table.vpn.id

  vpn_subnet_ipv6_cidr         = local.vpn_subnet_ipv6_cidr
  private_nat_gateway_id       = data.aws_nat_gateway.private_nat.id
  private_nat_ipv4_subnet_cidr = "10.0.255.0/24"

  security_group = data.aws_security_group.team.id
}


module "dns" {
  source = "../../modules/dns"

  team_number   = local.team_number
  external_ipv4 = module.network.firewall_private_external_ipv4 # public subnet, private ip
  external_ipv6 = module.network.firewall_public_ipv6
}


module "instances" {
  source = "../../modules/instances"

  team_number = local.team_number

  first_ipv6_cidr  = local.first_team_ipv6_subnet
  second_ipv6_cidr = local.second_team_ipv6_subnet
  third_ipv6_cidr  = local.third_team_ipv6_subnet
  ipv4_cidr        = local.team_ipv4_subnet

  pfSense_instance_interfaces = module.network.pfSense_instance_interfaces

  subnet_branch_id   = module.network.branch_subnet_id
  subnet_screened_id = module.network.screened_subnet_id
  subnet_private_id  = module.network.private_subnet_id

  security_group_id = data.aws_security_group.team.id
}
