terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
    }
  }
}

provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://gitlab.com/sami-group/homelab"
  }
}
