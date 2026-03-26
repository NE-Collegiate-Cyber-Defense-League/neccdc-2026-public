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
  instance_type = "t3a.medium"

  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name

  subnet_id = var.subnet_ids.corp_private

  ipv6_addresses = [
    cidrhost(var.cidrs.private_corp_ipv6, 939295911658254680) # 2600:1f26:1d:8aX2:d09:ca7:b15d:f158
  ]

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name    = "${var.team_number}-semaphore"
    service = "semaphore"
    org     = "corp"
  }
}
