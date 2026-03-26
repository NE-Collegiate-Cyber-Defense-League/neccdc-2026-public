variable "region" {
  description = "The region to deploy the network in"
  type        = string
}


variable "team_number" {
  description = "Team number"
  type        = number
}


variable "vpc_id" {
  description = "Team VPC id"
  type        = string
}


variable "vpn_route_table_id" {
  description = "VPN Route Table ID"
  type        = string
}


variable "private_nat_gateway_id" {
  description = "Private NAT Gateway ID"
  type        = string
}

variable "private_nat_ipv4_subnet_cidr" {
  description = "Private NAT Subnet IPv4 CIDR block"
  type        = string
}


variable "vpn_subnet_ipv6_cidr" {
  description = "VPN Subnet IPv6 CIDR block"
  type        = string
}


variable "remote_ipsec_cidr" {
  description = "CIDR block of the remote ipsec tunnel"
  type        = string
}

variable "remote_ipsec_staff" {
  description = "CIDR for the black/red teams over ipsec"
  type        = string
}

variable "remote_ipsec_team_cidr" {
  description = "Team CIDR over ipsec"
  type        = string
}

variable "ipsec_virtual_gateway" {
  description = "AWS Virtual Gateway ID"
  type        = string
}


variable "security_group" {
  description = "Security group to assign on firewall interfaces"
  type        = string
}


variable "global_ipv6_cidr" {
  description = "Global IPv6 CIDR block"
  type        = string
}

variable "cidrs" {
  description = "CIDR ranges for team subnets"
  type = object({
    public_corp_ipv4    = string
    dmz_corp_ipv4       = string
    private_branch_ipv4 = string
    public_corp_ipv6    = string
    dmz_corp_ipv6       = string
    private_corp_ipv6   = string
    public_branch_ipv6  = string
    private_branch_ipv6 = string
  })
}
