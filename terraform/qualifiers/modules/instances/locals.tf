locals {
  private_ipv4_cidr  = cidrsubnet(var.ipv4_cidr, 1, 0)
  screened_ipv4_cidr = cidrsubnet(var.ipv4_cidr, 2, 2)
  branch_ipv4_cidr   = cidrsubnet(var.ipv4_cidr, 3, 6)
  public_ipv4_cidr   = cidrsubnet(var.ipv4_cidr, 3, 7)
}
