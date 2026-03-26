output "firewall_private_external_ipv4" {
  value       = aws_network_interface.public.private_ip
  description = "The private IP in the public subnet of the pfSenseAlto firewall"
}

output "firewall_public_ipv4" {
  value       = aws_eip.pfSense_public.public_ip
  description = "The public IPv4 of the pfSenseAlto firewall"
}

output "firewall_public_ipv6" {
  value       = aws_network_interface.public.ipv6_addresses
  description = "The public IPv6 of the pfSenseAlto firewall"
}

output "pfSense_instance_interfaces" {
  description = "IDs of the pfSense Alto network interfaces"
  value = {
    branch   = aws_network_interface.branch.id
    private  = aws_network_interface.private.id
    screened = aws_network_interface.screened.id
    public   = aws_network_interface.public.id
  }
}


output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "ID of the public subnet"
}

output "branch_subnet_id" {
  value       = aws_subnet.branch.id
  description = "ID of the corp subnet"
}

output "screened_subnet_id" {
  value       = aws_subnet.screened.id
  description = "ID of the screened subnet"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ID of the private subnet"
}
