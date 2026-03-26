source "amazon-ebs" "debian_11" {
  instance_type = "t4g.small"
  region        = "us-east-2"
  profile       = "neccdc"
  imds_support  = "v2.0"

  # ami-02ecb571e29202895
  source_ami_filter {
    filters = {
      name                = "debian-12-arm64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true

    owners = ["136693071363"] # Debian official
  }

  ssh_username = "admin"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    volume_type           = "gp3"
    volume_size           = 10
  }
}
