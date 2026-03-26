data "aws_ami" "kiosk" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-kiosk-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "kiosk_1" {
  ami           = data.aws_ami.kiosk.image_id
  instance_type = "t4g.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.branch_private

  private_ip = cidrhost(var.cidrs.private_branch_ipv4, 201) # 10.100.X.201

  ipv6_addresses = [
    cidrhost(var.cidrs.private_branch_ipv6, 144115188075855873) # 2600:1f26:1d:8bX1:200::1
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-kiosk-1"
    service = "kiosk"
    org     = "branch"
  }
}

resource "aws_instance" "kiosk_2" {
  ami           = data.aws_ami.kiosk.image_id
  instance_type = "t4g.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.branch_private

  private_ip = cidrhost(var.cidrs.private_branch_ipv4, 202) # 10.100.X.202

  ipv6_addresses = [
    cidrhost(var.cidrs.private_branch_ipv6, 144115188075855874) # 2600:1f26:1d:8bX1:200::2
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-kiosk-2"
    service = "kiosk"
    org     = "branch"
  }
}
