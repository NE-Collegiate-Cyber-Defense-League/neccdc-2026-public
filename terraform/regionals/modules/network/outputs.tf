output "corp_pfSense_interfaces" {
  description = "AWS Interfaces for the Corp (ChefOps) pfSense"
  value = {
    dmz     = aws_network_interface.corp_dmz.id
    private = aws_network_interface.corp_private.id
    public  = aws_network_interface.corp_public.id
  }
}

output "branch_pfSense_interfaces" {
  description = "AWS Interfaces for the Branch (OCK) pfSense"
  value = {
    private = aws_network_interface.branch_private.id
    public  = aws_network_interface.branch_public.id
  }
}


output "subnet_ids" {
  description = "AWS Subnet IDs"
  value = {
    branch_private = aws_subnet.branch_private.id
    branch_public  = aws_subnet.branch_public.id
    corp_dmz       = aws_subnet.corp_dmz.id
    corp_private   = aws_subnet.corp_private.id
    corp_public    = aws_subnet.corp_public.id
  }
}


output "corp_pfSense_ips" {
  description = "IP addresses of the Corp (ChefOps) public pfSense interface"
  value = {
    ipv4          = aws_eip.pfSense_corp_public.public_ip
    ipv4_internal = aws_network_interface.corp_public.private_ip
    ipv6          = aws_network_interface.corp_public.ipv6_addresses
  }
}

output "branch_pfSense_ips" {
  description = "IP addresses of the Branch (OCK) public pfSense interface"
  value = {
    ipv6 = aws_network_interface.branch_public.ipv6_addresses
  }
}
