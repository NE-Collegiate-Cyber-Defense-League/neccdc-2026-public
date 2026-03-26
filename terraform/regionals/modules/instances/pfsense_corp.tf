data "aws_ami" "corp_pfsense" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-pfsense*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "corp_pfsense" {
  ami                  = data.aws_ami.corp_pfsense.image_id
  instance_type        = "t3a.medium"
  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name
  user_data            = "password=netadmin"

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = "optional"
    instance_metadata_tags      = "enabled"
    http_protocol_ipv6          = "enabled"
  }

  # network_interfaces are deprecated but using the recomened aws_network_interface_attachment don't work as well
  network_interface {
    network_interface_id = var.corp_pfSense_interfaces.public
    device_index         = 0
  }

  network_interface {
    network_interface_id = var.corp_pfSense_interfaces.private
    device_index         = 1
  }

  network_interface {
    network_interface_id = var.corp_pfSense_interfaces.dmz
    device_index         = 2
  }

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.team_number}-pfsense-corp"
    service = "pfsense"
    org     = "corp"
  }

  volume_tags = {
    service = "pfsense-corp"
    org     = "corp"
  }
}
