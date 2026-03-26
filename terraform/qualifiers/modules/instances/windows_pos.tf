data "aws_ami" "windows_pos" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-windows-pos-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "windows_pos" {
  ami                  = data.aws_ami.windows_pos.image_id
  instance_type        = "m7i.large"
  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_branch_id

  ipv6_addresses = [
    cidrhost(var.first_ipv6_cidr, 3405643776)
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-windows-pos"
    service = "windows-pos"
  }
}
