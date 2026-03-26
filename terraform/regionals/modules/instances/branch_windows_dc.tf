data "aws_ami" "branch_windows_dc" {
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


resource "aws_instance" "branch_windows_dc" {
  ami           = data.aws_ami.branch_windows_dc.image_id
  instance_type = "m8a.large"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.branch_private

  private_ip = cidrhost(var.cidrs.private_branch_ipv4, 64) # 10.100.X.64

  ipv6_addresses = [
    cidrhost(var.cidrs.private_branch_ipv6, 61453) # 2600:1f26:1d:8bX1::f00d
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-dc02"
    service = "windows"
    org     = "branch"
  }
}
