locals {
  ssh_key_pub = yamldecode(file("../group_vars/all/vars.yml"))["template_vm_ubuntu_defaults"]["ssh_key"]
}

provider "ansiblevault" {
  vault_path  = "../.vault-password"
  root_folder = "../"
}

data "ansiblevault_path" "proxmox_api_user" {
  path = "./group_vars/all/vault.yml"
  key = "vault_pve.proxmox_api_user"
}

data "ansiblevault_path" "proxmox_api_pass" {
  path = "./group_vars/all/vault.yml"
  key = "vault_pve.proxmox_api_pass"
}

data "ansiblevault_path" "proxmox_host" {
  path = "./group_vars/all/vault.yml"
  key = "vault_pve.proxmox_host"
}

data "ansiblevault_path" "proxmox_port" {
  path = "./group_vars/all/vault.yml"
  key = "vault_proxmox_port"
}

data "ansiblevault_path" "proxmox_node" {
  path = "./group_vars/all/vault.yml"
  key = "vault_pve.proxmox_node"
}

data "ansiblevault_path" "domain_name" {
  path = "./group_vars/all/vault.yml"
  key = "vault_domain_name"
}

data "ansiblevault_path" "main_user" {
  path = "./group_vars/all/vault.yml"
  key = "vault_main_user"
}

data "ansiblevault_path" "vault_vm_network" {
  path = "./group_vars/all/vault.yml"
  key = "vault_domain_name"
}

data "ansiblevault_path" "vault_vm_gateway" {
  path = "./group_vars/all/vault.yml"
  key = "vault_main_user"
}

output "debug" {
    super_secret = data.ansiblevault_path.proxmox_port
}
