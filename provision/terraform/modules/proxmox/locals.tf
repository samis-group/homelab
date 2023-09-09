locals {
  ssh_key_pub = yamldecode(file("../group_vars/all/vars.yml"))["vm_defaults"]["ssh_key"]
}
