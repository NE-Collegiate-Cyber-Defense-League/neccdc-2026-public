source "amazon-ebs" "debian_11" {
  ami_name      = "packer-grafana-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  instance_type = "t3a.large"
  region        = "us-east-2"
  profile       = "neccdc"
  imds_support  = "v2.0"

  # ami-02e48866fcfad8bf8
  source_ami_filter {
    filters = {
      name                = "debian-11-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"] # Debian official
  }

  ssh_username = "admin" # Default for Debian AMIs

  tags = {
    Name = "packer-grafana"
    date = formatdate("YYYY-MM-DD hh:mm", timestamp())
  }

  run_tags = {
    Name = "packer-build-grafana"
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
    volume_size           = 40
  }
}
