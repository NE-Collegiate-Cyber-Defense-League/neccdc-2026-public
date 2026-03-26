data "aws_ami" "corp_teleport" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-teleport-corp-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "corp_teleport" {
  ami           = data.aws_ami.corp_teleport.image_id
  instance_type = "t3a.medium"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.corp_dmz

  private_ip = cidrhost(var.cidrs.dmz_corp_ipv4, 128) # 10.3.X.128

  user_data = "export ROOT_PASSWORD=dQw4w9WgXcQ"

  ipv6_addresses = [
    cidrhost(var.cidrs.dmz_corp_ipv6, 49374) # 2600:1f26:1d:8aX1::c0de
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-teleport-corp"
    service = "teleport"
    org     = "corp"
  }
}
