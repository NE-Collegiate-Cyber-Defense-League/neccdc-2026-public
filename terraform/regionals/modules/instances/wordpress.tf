data "aws_ami" "wordpress" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-wordpress-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.wordpress.image_id
  instance_type = "t3a.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.corp_dmz

  private_ip = cidrhost(var.cidrs.dmz_corp_ipv4, 200) # 10.3.X.200

  ipv6_addresses = [
    cidrhost(var.cidrs.dmz_corp_ipv6, 3193420496) # 2600:1f26:1d:8aX1::be57:bad0
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-wordpress"
    service = "wordpress"
    org     = "corp"
  }
}
