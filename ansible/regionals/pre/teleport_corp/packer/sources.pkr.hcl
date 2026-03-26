# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-teleport-corp-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # ami-09588768f512a824a
  source_ami_filter {
    filters = {
      name                = "ubuntu-pro-server/images/hvm-ssd/ubuntu-xenial-16.04-amd64-pro-server-20251001"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  instance_type               = "t3a.medium"
  associate_public_ip_address = true

  profile = "neccdc"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  tags = {
    Name = "packer-teleport-corp"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-build-teleport-corp"
  }
}
