# https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/data-source/ami
# ami-09588768f512a824a
data "amazon-ami" "image" {
  filters = {
    name = "ubuntu-pro-server/images/hvm-ssd/ubuntu-xenial-16.04-amd64-pro-server-20251001"
  }
  owners = ["099720109477"]
  most_recent = true
}


# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-teleport-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  source_ami                  = data.amazon-ami.image.id
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
    Name = "packer-teleport"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-build-teleport"
  }
}
