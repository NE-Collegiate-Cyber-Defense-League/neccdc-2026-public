# https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/data-source/ami
# Was originally going to use 9.3 but the image was removed ;/ so now I cloned the image locally
# ami-0e612cb1b072c3f15
data "amazon-ami" "image" {
  profile = "neccdc"

  filters = {
    architecture = "arm64"
    name         = "Rocky-9-EC2-LVM-9.4-20240509.0.aarch64"
  }
  owners      = ["self"]
  most_recent = true
}


# https://www.packer.io/plugins/builders/amazon/ebs
source "amazon-ebs" "vm" {
  region            = "us-east-2"
  ami_name          = "packer-falco-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  subnet_id         = "subnet-04255ba24872d7d79"
  security_group_id = "sg-027af0024a1813997"

  source_ami                  = data.amazon-ami.image.id
  instance_type               = "t4g.small"
  associate_public_ip_address = true

  profile = "neccdc"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 11
    delete_on_termination = true
  }

  tags = {
    Name = "packer-falco"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }
  run_tags = {
    Name = "packer-build-falco"
  }
}
