# https://www.packer.io/plugins/provisioners/ansible/ansible

source "amazon-ebs" "debian_11" {
  ami_name      = "packer-kiosk-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  instance_type = "t4g.small"
  region        = "us-east-2"
  profile       = "neccdc"
  imds_support  = "v2.0"

  source_ami_filter {
    filters = {
      name                = "debian-11-arm64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = ["136693071363"] # Debian official
  }

  ssh_username = "admin"

  tags = {
    Name = "kiosk"
    Year = "2026"
  }

  run_tags = {
    Name = "packer-build-kiosk"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    volume_size           = 10
  }
}

build {
  sources = [
    "source.amazon-ebs.debian_11"
  ]
  provisioner "ansible" {
    playbook_file = "../playbook.yaml"
    host_alias    = "packer"
    use_proxy     = false
  }
}
