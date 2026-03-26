variable "team_number" {
  type        = number
  description = "Team number"
}

variable "ipv4_cidr" {
  type        = string
  description = "IPv4 CIDR block for the teams subnet"
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


variable "subnet_branch_id" {
  type        = string
  description = "The AWS branch subnet ID"
}

variable "subnet_screened_id" {
  type        = string
  description = "The AWS screened subnet ID"
}

variable "subnet_private_id" {
  type        = string
  description = "The AWS Subnet ID for the private subnet"
}


variable "key_pair" {
  type        = string
  default     = "black-team"
  description = "Key pair to use for all instances"
}

variable "security_group_id" {
  type        = string
  description = "ID of the instances shared security group"
}

variable "pfSense_instance_interfaces" {
  description = "Map of Palo Alto network interface IDs"
  type = object({
    branch   = string
    screened = string
    private  = string
    public   = string
  })
}
