data "aws_ami" "kiosk_minimal" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-kiosk-minimal-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "kiosk_minimal" {
  count = var.kiosk_minimal ? 1 : 0

  ami           = data.aws_ami.kiosk_minimal.image_id
  instance_type = "t4g.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.branch_private

  private_ip = cidrhost(var.cidrs.private_branch_ipv4, 203) # 10.100.X.203

  ipv6_addresses = [
    cidrhost(var.cidrs.private_branch_ipv6, 144115188075855875) # 2600:1f26:1d:8bX1:200::3
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-kiosk-3"
    service = "kiosk"
    org     = "branch"
  }
}
