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

provider "doppler" {
  # Token can be provided with the environment variable `TF_VAR_doppler_token` instead
  doppler_token = var.doppler_token
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# module "cloudflare" {
#   source = "./modules/cloudflare"
# }

# module "proxmox" {
#   source = "./modules/proxmox"
# }
