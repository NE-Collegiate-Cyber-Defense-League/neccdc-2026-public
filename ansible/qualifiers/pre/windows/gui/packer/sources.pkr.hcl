locals { timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp()) }

variable "windows_username" {
  type        = string
  description = "Username when authenticating to Windows, default is Administrator."
  default     = "Administrator"
}

variable "windows_password" {
  type        = string
  description = "Password for the Windows user."
  sensitive   = true
}

data "amazon-ami" "windows" {
  filters = {
    name                = "Windows_Server-2022-English-Full-Base*"
  }
  owners      = ["801119661308"]
  most_recent = true
}

source "amazon-ebs" "firstrun-windows" {
  region                      = "us-east-2"
  ami_name                    = "packer-windows-server-${local.timestamp}"
  source_ami                  = data.amazon-ami.windows.id
  instance_type               = "c8a.4xlarge"
  security_group_id           = "sg-027af0024a1813997"
  subnet_id                   = "subnet-04255ba24872d7d79"
  associate_public_ip_address = true

  profile = "neccdc"

  # EBS Storage Volume
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 60
    delete_on_termination = true
  }

  # Fast launch settings
  fast_launch {
    enable_fast_launch = false
  }

  # Windows specific settings
  disable_stop_instance = true
  communicator          = "winrm"
  winrm_username        = var.windows_username
  winrm_password        = var.windows_password
  winrm_insecure        = true
  winrm_timeout         = "15m"
  winrm_use_ssl         = false

  user_data = templatefile("${path.root}/templates/bootstrap.pkrtpl.hcl", {
    windows_username = var.windows_username,
    windows_password = var.windows_password
  })

  tags = {
    "Name" = "packer-windows-server"
    "Date" = "${local.timestamp}"
  }
  run_tags = {
    "Name" = "packer-build-windows"
  }
}