terraform {
  cloud {
    organization = "sami-group"
    workspaces {
      name = "homelab-cloudflare"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.29.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
  }
}
