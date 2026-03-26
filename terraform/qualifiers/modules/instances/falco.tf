data "aws_ami" "falco" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-falco-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "falco" {
  ami           = data.aws_ami.falco.image_id
  instance_type = "t4g.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(local.private_ipv4_cidr, 100)

  ipv6_addresses = [
    cidrhost(var.second_ipv6_cidr, 4196139008)
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-falco"
    service = "falco"
  }
}
