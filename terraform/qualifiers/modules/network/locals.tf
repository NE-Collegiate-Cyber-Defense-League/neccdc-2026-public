locals {
  branch_ipv4_cidr   = cidrsubnet(var.ipv4_cidr, 3, 6)
  private_ipv4_cidr  = cidrsubnet(var.ipv4_cidr, 1, 0)
  screened_ipv4_cidr = cidrsubnet(var.ipv4_cidr, 2, 2)
  public_ipv4_cidr   = cidrsubnet(var.ipv4_cidr, 3, 7)
}
