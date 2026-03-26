data "aws_ami" "pfsense" {
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

resource "aws_instance" "pfsense" {
  ami                  = data.aws_ami.pfsense.image_id
  instance_type        = "m7g.xlarge"
  key_name             = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.session_manager.name
  user_data            = "password=pfsadmin"

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = "optional"
    instance_metadata_tags      = "enabled"
  }

  # network_interfaces are deprecated but using the recomened aws_network_interface_attachment don't work as well
  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.public
    device_index         = 0
  }

  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.private
    device_index         = 1
  }

  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.screened
    device_index         = 2
  }

  network_interface {
    network_interface_id = var.pfSense_instance_interfaces.branch
    device_index         = 3
  }

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.team_number}-pfsense"
    service = "pfsense"
  }

  volume_tags = {
    service = "pfsense"
  }
}
