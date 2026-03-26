data "aws_ami" "semaphore" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-semaphore-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "semaphore" {
  ami           = data.aws_ami.semaphore.image_id
  instance_type = "t3a.small"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id  = var.subnet_private_id
  private_ip = cidrhost(local.private_ipv4_cidr, 48)

  ipv6_addresses = [
    cidrhost(var.second_ipv6_cidr, 3735879680)
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-semaphore"
    service = "semaphore"
  }
}
