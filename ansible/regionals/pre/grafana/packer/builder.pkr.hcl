# https://www.packer.io/plugins/provisioners/ansible/ansible

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
