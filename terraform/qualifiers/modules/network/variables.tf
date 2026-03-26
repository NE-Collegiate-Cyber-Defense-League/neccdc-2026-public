variable "ipv4_cidr" {
  type        = string
  description = "IPv4 CIDR block for the teams subnet"
}

variable "region" {
  type        = string
  description = "The region to deploy the network in"
}

variable "team_number" {
  type        = number
  description = "Team number"
}

variable "vpc_id" {
  type        = string
  description = "Team VPC id"
}

variable "vpn_route_table_id" {
  type        = string
  description = "VPN Route Table ID"
}

variable "private_nat_gateway_id" {
  type        = string
  description = "Private NAT Gateway ID"
}

variable "private_nat_ipv4_subnet_cidr" {
  type        = string
  description = "Private NAT Subnet IPv4 CIDR block"
}

variable "vpn_subnet_ipv6_cidr" {
  type        = string
  description = "VPN Subnet IPv6 CIDR block"
}

variable "first_ipv6_cidr" {
  type        = string
  description = "First IPv6 CIDR block for the teams subnet"
}

variable "second_ipv6_cidr" {
  type        = string
  description = "Second IPv6 CIDR block for the teams subnet"
}

variable "third_ipv6_cidr" {
  type        = string
  description = "Third IPv6 CIDR block for the teams subnet"
}

variable "global_ipv6_cidr" {
  type        = string
  description = "Global IPv6 CIDR block"
}

variable "security_group" {
  type        = string
  description = "Security group to assign on firewall interfaces"
}
