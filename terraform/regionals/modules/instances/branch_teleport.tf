data "aws_ami" "branch_teleport" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-teleport-branch-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "branch_teleport" {
  ami           = data.aws_ami.branch_teleport.image_id
  instance_type = "t4g.medium"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.branch_private

  private_ip = cidrhost(var.cidrs.private_branch_ipv4, 100) # 10.100.X.100

  ipv6_addresses = [
    cidrhost(var.cidrs.private_branch_ipv6, 48879) # 2600:1f26:1d:8bX1::beef
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-teleport-branch"
    service = "teleport"
    org     = "branch"
  }
}
