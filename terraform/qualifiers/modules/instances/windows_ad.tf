data "aws_ami" "windows_server" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-windows-server*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "windows_ad" {
  ami                  = data.aws_ami.windows_server.image_id
  instance_type        = "m7i.large"
  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(local.private_ipv4_cidr, 120)

  ipv6_addresses = [
    cidrhost(var.second_ipv6_cidr, 12346494073709150913)
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-windows-ad"
    service = "windows-ad"
  }
}
