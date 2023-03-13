terraform {
  cloud {
    organization = "sami-group"
    workspaces {
      name = "flux"
    }
  }
  required_providers {
    flux = {
      source  = "fluxcd/flux"
    }
  }
}
