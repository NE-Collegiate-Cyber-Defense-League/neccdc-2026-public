# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-wordpress-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # ami-0503ed50b531cc445
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  instance_type               = "t3a.small"
  associate_public_ip_address = true

  profile = "neccdc"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name = "packer-wordpress"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-build-wordpress"
  }
}
