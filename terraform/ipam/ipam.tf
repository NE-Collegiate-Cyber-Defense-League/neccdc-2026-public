resource "aws_vpc_ipam" "main" {
  operating_regions {
    region_name = var.region
  }

  description = "Main IPAM for IPv6"
}

resource "aws_vpc_ipam_scope" "ipv6" {
  ipam_id     = aws_vpc_ipam.main.id
  description = "IPv6 scope"
}


resource "aws_vpc_ipam_pool" "ipv6_first" {
  address_family = "ipv6"
  ipam_scope_id  = aws_vpc_ipam_scope.ipv6.id
  locale         = var.region
  description    = "First IPv6 pool"
}

resource "aws_vpc_ipam_pool_cidr" "ipv6_first" {
  ipam_pool_id   = aws_vpc_ipam_pool.ipv6_first.id
  netmask_length = 56
}


resource "aws_vpc_ipam_pool" "ipv6_second" {
  address_family = "ipv6"
  ipam_scope_id  = aws_vpc_ipam_scope.ipv6.id
  locale         = var.region
  description    = "Second IPv6 pool"
}

resource "aws_vpc_ipam_pool_cidr" "ipv6_second" {
  ipam_pool_id   = aws_vpc_ipam_pool.ipv6_second.id
  netmask_length = 56
}


resource "aws_vpc_ipam_pool" "ipv6_third" {
  address_family = "ipv6"
  ipam_scope_id  = aws_vpc_ipam_scope.ipv6.id
  locale         = var.region
  description    = "Third IPv6 pool"
}

resource "aws_vpc_ipam_pool_cidr" "ipv6_third" {
  ipam_pool_id   = aws_vpc_ipam_pool.ipv6_third.id
  netmask_length = 56
}
