resource "aws_subnet" "screened" {
  vpc_id                  = var.vpc_id
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  cidr_block              = local.screened_ipv4_cidr

  tags = {
    Name    = "${var.team_number}-screened"
    network = "screened"
  }
}

resource "aws_network_acl_association" "screened" {
  network_acl_id = aws_network_acl.this.id
  subnet_id      = aws_subnet.screened.id
}
