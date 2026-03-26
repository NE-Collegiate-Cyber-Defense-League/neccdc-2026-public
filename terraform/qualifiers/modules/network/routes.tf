# Note: The branch subnet does not need a route since ipv6 cannot go through the private nat gateway

resource "aws_route" "private_vpn" {
  route_table_id         = var.vpn_route_table_id
  destination_cidr_block = aws_subnet.private.cidr_block
  nat_gateway_id         = var.private_nat_gateway_id
}

resource "aws_route" "public_vpn" {
  route_table_id         = var.vpn_route_table_id
  destination_cidr_block = aws_subnet.public.cidr_block
  nat_gateway_id         = var.private_nat_gateway_id
}

resource "aws_route" "screened_vpn" {
  route_table_id         = var.vpn_route_table_id
  destination_cidr_block = aws_subnet.screened.cidr_block
  nat_gateway_id         = var.private_nat_gateway_id
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = data.aws_route_table.public.id
}


resource "aws_route_table" "branch" {
  vpc_id = var.vpc_id

  route {
    ipv6_cidr_block      = "::/0"
    network_interface_id = aws_network_interface.branch.id
  }

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.branch.id
  }

  route {
    cidr_block           = aws_subnet.screened.cidr_block
    network_interface_id = aws_network_interface.branch.id
  }

  route {
    cidr_block           = aws_subnet.private.cidr_block
    network_interface_id = aws_network_interface.branch.id
  }

  route {
    cidr_block           = aws_subnet.public.cidr_block
    network_interface_id = aws_network_interface.branch.id
  }


  route {
    ipv6_cidr_block      = aws_subnet.branch.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.private.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.public.ipv6_cidr_block
    network_interface_id = aws_network_interface.branch.id
  }

  tags = {
    Name    = "${var.team_number}-branch"
    network = "branch"
  }
}

resource "aws_route_table_association" "branch" {
  subnet_id      = aws_subnet.branch.id
  route_table_id = aws_route_table.branch.id
}



resource "aws_route_table" "screened" {
  vpc_id = var.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.screened.id
  }

  route {
    cidr_block           = aws_subnet.screened.cidr_block
    network_interface_id = aws_network_interface.screened.id
  }

  route {
    cidr_block           = aws_subnet.private.cidr_block
    network_interface_id = aws_network_interface.screened.id
  }

  route {
    cidr_block           = aws_subnet.public.cidr_block
    network_interface_id = aws_network_interface.screened.id
  }

  tags = {
    Name    = "${var.team_number}-screened"
    network = "screened"
  }
}

resource "aws_route_table_association" "screened" {
  subnet_id      = aws_subnet.screened.id
  route_table_id = aws_route_table.screened.id
}



resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.private.id
  }

  route {
    ipv6_cidr_block      = "::/0"
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block           = aws_subnet.screened.cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block           = aws_subnet.private.cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    cidr_block           = aws_subnet.public.cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.branch.ipv6_cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.private.ipv6_cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  route {
    ipv6_cidr_block      = aws_subnet.public.ipv6_cidr_block
    network_interface_id = aws_network_interface.private.id
  }

  tags = {
    Name    = "${var.team_number}-private"
    network = "private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
