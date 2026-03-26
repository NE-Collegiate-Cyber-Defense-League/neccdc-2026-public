# https://www.packer.io/plugins/provisioners/ansible/ansible

build {
  source "source.amazon-ebs.debian_11" {
    name = "full"
    ami_name = "packer-kiosk-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
    tags = {
      Name = "packer-kiosk"
      date = formatdate("YYYY-MM-DD hh:mm", timestamp())
    }
    run_tags = {
      Name = "packer-build-kiosk"
    }
  }

  source "source.amazon-ebs.debian_11" {
    name = "minimal"
    ami_name = "packer-kiosk-minimal-${formatdate("YYYY-MMM-DD-hh-mm", timestamp())}"
    tags = {
      Name = "packer-kiosk-minimal"
      date = formatdate("YYYY-MM-DD hh:mm", timestamp())
    }
    run_tags = {
      Name = "packer-build-kiosk-minimal"
    }
  }

  provisioner "ansible" {
    only              = ["amazon-ebs.full"]
    playbook_file     = "../playbook.yaml"
    host_alias        = "packer"
    use_proxy         = false
    extra_arguments   = ["-e", "full_provision=true"]
  }

  provisioner "ansible" {
    only              = ["amazon-ebs.minimal"]
    playbook_file     = "../playbook.yaml"
    host_alias        = "packer"
    use_proxy         = false
    extra_arguments   = ["-e", "full_provision=false"]
  }
}
