build {
  name    = "pfsense-builder"
  sources = ["source.amazon-ebs.pfsense"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yaml"
    user          = "admin" # Default for pfSense AMIs
    use_proxy     = false
  }
}
