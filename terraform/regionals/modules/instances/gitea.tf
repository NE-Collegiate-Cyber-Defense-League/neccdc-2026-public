data "aws_ami" "gitea" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-gitea-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "gitea" {
  ami           = data.aws_ami.gitea.image_id
  instance_type = "t4g.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.corp_private

  ipv6_addresses = [
    cidrhost(var.cidrs.private_corp_ipv6, 65261) # 2600:1f26:1d:8aX2::feed
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  metadata_options {
    http_protocol_ipv6 = "enabled"
  }

  tags = {
    Name    = "${var.team_number}-gitea"
    service = "gitea"
    org     = "corp"
  }
}
