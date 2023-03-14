locals {
  ssh_key_pub = yamldecode(file("../group_vars/all/vars.yml"))["template_vm_ubuntu_defaults"]["ssh_key"]
}
