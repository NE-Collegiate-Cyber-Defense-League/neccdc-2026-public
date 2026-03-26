# https: //www.packer.io/plugins/provisioners/ansible/ansible

build {
  name    = "pfsense-builder"
  sources = ["source.amazon-ebs.vm"]

  provisioner "ansible" {
    playbook_file   = "../ansible/playbook.yaml"
    user            = "${var.pfsense_username}"
    use_proxy       = false
    extra_arguments = [
      "-e", "pfsense_version=${var.pfsense_version}",
    ]
  }
}
