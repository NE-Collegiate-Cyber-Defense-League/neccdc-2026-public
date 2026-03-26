variable "team_number" {
  description = "The ID of the team"
  type        = string
}

variable "corp_pfSense_ips" {
  description = "IP addresses of the Ccorp (ChefOps) public pfSense interface"
  type = object({
    ipv4          = string
    ipv4_internal = string
    ipv6          = list(string)
  })
}

variable "branch_pfSense_ips" {
  description = "IP addresses of the Branch (OCK) public pfSense interface"
  type = object({
    ipv6 = list(string)
  })
}
