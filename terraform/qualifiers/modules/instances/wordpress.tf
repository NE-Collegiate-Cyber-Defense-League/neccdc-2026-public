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

  subnet_id  = var.subnet_screened_id
  private_ip = cidrhost(local.screened_ipv4_cidr, 60)

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-wordpress"
    service = "wordpress"
  }
}
