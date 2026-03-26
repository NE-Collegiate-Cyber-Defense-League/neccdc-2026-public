data "aws_ami" "branch_windows_pos" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-windows-pos*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "branch_windows_pos" {
  ami           = data.aws_ami.branch_windows_pos.image_id
  instance_type = "m8a.large"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.branch_private

  private_ip = cidrhost(var.cidrs.private_branch_ipv4, 37) # 10.100.X.37

  ipv6_addresses = [
    cidrhost(var.cidrs.private_branch_ipv6, 51966) # 2600:1f26:1d:8bX1::cafe
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-pos"
    service = "windows"
    org     = "branch"
  }
}
