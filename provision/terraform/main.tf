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
    flux = {
      source  = "fluxcd/flux"
    }
  }
}
