variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region to deploy resources"
}

variable "remote_subnet_cidr" {
  type        = string
  default     = "172.31.0.0/16"
  description = "The internal host network cidr block"
}

variable "remote_ipsec_ip" {
  type        = string
  default     = "134.241.46.1"
  description = "The pubic IP address of the IPSec VPN endpoint"
}
