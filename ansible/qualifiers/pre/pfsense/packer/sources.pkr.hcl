locals { timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp()) }

variable "pfsense_username" {
  type        = string
  description = "Username when authenticating to pfsense, default is admin."
  default     = "admin"
}

variable "pfsense_password" {
  type        = string
  description = "Password for the pfsense user."
  sensitive   = true
}

variable "pfsense_version" {
  type        = string
  description = "Version of pfSense to install."
  default     = "25.11"
}

data "amazon-ami" "pfsense" {
  filters = {
    name = "pfSense-plus-ec2-25.11-RELEASE-aarch64*"
  }
  owners      = ["aws-marketplace"]
  most_recent = true
}

source "amazon-ebs" "vm" {
  region                      = "us-east-2"
  ami_name                    = "packer-pfsense-${local.timestamp}"
  source_ami                  = data.amazon-ami.pfsense.id
  instance_type               = "m7g.xlarge"
  subnet_id                   = "subnet-04255ba24872d7d79"
  security_group_id           = "sg-027af0024a1813997"
  associate_public_ip_address = true
  profile                     = "neccdc"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 32
    delete_on_termination = true
  }

  user_data = "password=${var.pfsense_password}"

  communicator         = "ssh"
  ssh_username         = "${var.pfsense_username}"
  ssh_password         = "${var.pfsense_password}"
  ssh_keypair_name     = "black-team"
  ssh_private_key_file = "../../../../../documents/black_team/id_rsa"

  tags = {
    "Name" = "packer-pfsense"
    "Date" = "${local.timestamp}"
  }
  run_tags = {
    "Name" = "packer-tmp-build-server-pfsense"
  }
}
