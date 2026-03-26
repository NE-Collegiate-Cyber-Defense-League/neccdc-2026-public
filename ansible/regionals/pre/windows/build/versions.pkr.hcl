# https://github.com/hashicorp/packer-plugin-amazon
# https://github.com/hashicorp/packer-plugin-ansible

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.8.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1.4"
    }
    windows-update = {
      version = "0.17.2"
      source  = "github.com/rgl/windows-update"
    }
  }
}
