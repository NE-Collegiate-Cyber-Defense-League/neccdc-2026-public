source "amazon-ebs" "vm" {
  ami_name      = "packer-gitea-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  instance_type = "t4g.small"
  region        = "us-east-2"
  profile       = "neccdc"
  imds_support  = "v2.0"

  # ami-0fd78cb83ae5b2000
  source_ami_filter {
    filters = {
      name                = "RHEL-9.2.0_HVM-*"
      architecture        = "arm64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }

  ssh_username = "ec2-user"

  tags = {
    Name = "gitea"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }

  run_tags = {
    Name = "packer-build-gitea"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    volume_type           = "gp3"
    volume_size           = 24
  }
}
