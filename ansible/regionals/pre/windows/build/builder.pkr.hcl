locals {
  shared_path = "${path.root}/../shared"
}

build {
  name = "windows-builder"

  sources = ["source.amazon-ebs.windows"]

  provisioner "powershell" {
    script = "${local.shared_path}/scripts/ConfigureRemotingForAnsible.ps1"
  }

  provisioner "ansible" {
    playbook_file = "${local.shared_path}/ansible/${var.playbook}"
    use_proxy     = false
    user          = "${var.windows_username}"
    extra_arguments = [
      "-e", "ansible_winrm_server_cert_validation=ignore",
    ]
  }

  provisioner "file" {
    content = templatefile("${local.shared_path}/templates/agent-config.pkrtpl.hcl", {
      windows_username = "${var.windows_username}",
      windows_password = "${var.windows_password}"
    })
    destination = "C:\\ProgramData\\Amazon\\EC2Launch\\config\\agent-config.yml"
  }

  provisioner "file" {
    content = templatefile("${local.shared_path}/templates/amazon-ssm-agent.pkrtpl.hcl", {
      region = "us-east-2",
    })
    destination = "C:\\Program Files\\Amazon\\SSM\\amazon-ssm-agent.json"
  }

  provisioner "powershell" {
    inline = [
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' reset --clean",
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' sysprep --shutdown --clean",
    ]
  }
}
