source "amazon-ebs" "pfsense" {
  ami_name      = "packer-pfsense-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  instance_type = "t3a.medium"
  region        = "us-east-2"
  profile       = "neccdc"
  imds_support  = "v2.0"

  source_ami_filter {
    filters = {
      name                = "pfSense-plus-ec2-25.11.1-RELEASE-amd64*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true

    owners = ["aws-marketplace"]
  }

  ssh_username = "admin" # Default for pfSense AMIs
  user_data    = "password=netadmin" # Set password for default admin user

  tags = {
    Name = "packer-pfsense"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }

  run_tags = {
    Name = "packer-build-pfsense"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 32
  }
}
