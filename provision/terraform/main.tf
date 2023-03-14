terraform {
  cloud {
    organization = "sami-group"
    workspaces {
      name = "terraform"
    }
  }
  required_providers {
    doppler = {
      source = "DopplerHQ/doppler"
    }
  }
}

# module "cloudflare" {
#   source = "./modules/cloudflare"
# }

# module "proxmox" {
#   source = "./modules/proxmox"
# }
