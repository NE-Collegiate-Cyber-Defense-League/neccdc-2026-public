source "amazon-ebs" "windows" {
  ami_name      = "${var.ami_name}-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
  instance_type = "m8a.2xlarge"
  region        = "us-east-2"
  profile       = "neccdc"
  imds_support  = "v2.0"

  source_ami_filter {
    filters = {
      name                = "${var.source_ami}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true

    owners = ["801119661308"]
  }

  communicator   = "winrm"
  winrm_username = "${var.windows_username}"
  winrm_password = "${var.windows_password}"

  disable_stop_instance = true

  user_data = templatefile("${local.shared_path}/templates/bootstrap.pkrtpl.hcl", {
    windows_username = "${var.windows_username}",
    windows_password = "${var.windows_password}"
  })

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 60
  }

  tags = {
    Name    = "${var.ami_name}"
    Date    = formatdate("YYYY-MM-DD hh:mm", timestamp())
    Sysprep = "true"
  }

  run_tags = {
    Name = "packer-${var.ami_name}"
  }
}
