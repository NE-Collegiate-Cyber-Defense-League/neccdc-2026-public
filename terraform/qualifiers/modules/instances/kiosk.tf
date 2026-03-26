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

  subnet_id = var.subnet_branch_id

  ipv6_addresses = [
    cidrhost(var.first_ipv6_cidr, 16777217)
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-kiosk-1"
    service = "kiosk"
  }
}

resource "aws_instance" "kiosk_2" {
  ami           = data.aws_ami.kiosk.image_id
  instance_type = "t4g.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_branch_id

  ipv6_addresses = [
    cidrhost(var.first_ipv6_cidr, 16777218)
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-kiosk-2"
    service = "kiosk"
  }
}
