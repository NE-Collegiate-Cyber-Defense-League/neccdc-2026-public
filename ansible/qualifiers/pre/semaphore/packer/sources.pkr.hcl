# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-semaphore-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # ami-0b52d97d6dcc9177b
  source_ami_filter {
    filters = {
      name                = "suse-sles-15-sp6-v20251016-hvm-ssd-x86_64"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["013907871322"]
  }

  instance_type               = "t3a.small"
  associate_public_ip_address = true

  profile = "neccdc"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  tags = {
    Name = "packer-semaphore"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-build-semaphore"
  }
}
