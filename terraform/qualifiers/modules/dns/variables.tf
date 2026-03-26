variable "team_number" {
  type        = string
  description = "The ID of the team"
}

variable "external_ipv4" {
  type        = string
  description = "The IPv4 address of the firewall"
}

variable "external_ipv6" {
  type        = list(string)
  description = "The IPv6 address of the firewall"
}
