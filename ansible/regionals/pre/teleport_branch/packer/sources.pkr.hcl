# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-teleport-branch-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  # ami-0df12747e32afc1bb
  source_ami_filter {
    filters = {
      architecture = "arm64"
      name         = "Rocky-9-EC2-Base-9.7-20251123.2.aarch64"
    }
    most_recent = true
    owners      = ["self"]
  }

  instance_type               = "t4g.medium"
  associate_public_ip_address = true

  profile = "neccdc"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  tags = {
    Name = "packer-teleport-branch"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-build-teleport-branch"
  }
}
