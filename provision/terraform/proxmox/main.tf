terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
    ansiblevault = {
      source = "MeilleursAgents/ansiblevault"
      version = "2.2.0"
    }
  }
}
