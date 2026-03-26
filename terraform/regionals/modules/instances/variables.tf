variable "team_number" {
  description = "Team number"
  type        = number
}


variable "cidrs" {
  description = "CIDR ranges for team subnets"
  type = object({
    dmz_corp_ipv4       = string
    private_branch_ipv4 = string
    dmz_corp_ipv6       = string
    private_corp_ipv6   = string
    private_branch_ipv6 = string
  })
}


variable "key_pair" {
  default     = "black-team"
  description = "Key pair to use for all instances"
  type        = string
}


variable "security_group_id" {
  description = "ID of the instances shared security group"
  type        = string
}


variable "subnet_ids" {
  description = "AWS Subnet IDs"
  type = object({
    branch_private = string
    branch_public  = string
    corp_dmz       = string
    corp_private   = string
    corp_public    = string
  })
}


variable "branch_pfSense_interfaces" {
  description = "AWS Interfaces for the Branch (OCK) pfSense"
  type = object({
    private = string
    public  = string
  })
}

variable "corp_pfSense_interfaces" {
  description = "AWS Interfaces for the Corp (ChefOps) pfSense"
  type = object({
    dmz     = string
    private = string
    public  = string
  })
}


variable "kiosk_minimal" {
  default     = true
  description = "Should kiosk #3 be created"
  type        = bool
}
