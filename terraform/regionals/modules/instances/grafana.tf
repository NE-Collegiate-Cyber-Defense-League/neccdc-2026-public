data "aws_ami" "grafana" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-grafana-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "grafana" {
  ami           = data.aws_ami.grafana.image_id
  instance_type = "t3a.large"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.corp_private

  ipv6_addresses = [
    cidrhost(var.cidrs.private_corp_ipv6, 11879879540736) # 2600:1f26:1d:8aX2:0:ace::
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-grafana"
    service = "grafana"
    org     = "corp"
  }
}
