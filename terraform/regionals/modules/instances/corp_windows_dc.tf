data "aws_ami" "corp_windows_dc" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-windows-core*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "corp_windows_dc" {
  ami           = data.aws_ami.corp_windows_dc.image_id
  instance_type = "m8a.large"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.corp_private

  ipv6_addresses = [
    cidrhost(var.cidrs.private_corp_ipv6, 173) # 2600:1f26:1d:8aX2::ad
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-dc01"
    service = "windows"
    org     = "corp"
  }
}
