# https://www.packer.io/plugins/provisioners/ansible/ansible

build {
  sources = [
    "source.amazon-ebs.vm"
  ]
  provisioner "ansible" {
    playbook_file = "../playbook.yaml"
    host_alias    = "packer"
    use_proxy     = false
  }
}
