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
  instance_type = "t3.large"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(local.private_ipv4_cidr, 32)

  ipv6_addresses = [
    cidrhost(var.second_ipv6_cidr, 3203334144)
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-grafana"
    service = "grafana"
  }
}
