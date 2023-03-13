# https://registry.terraform.io/providers/fluxcd/flux/latest/docs
terraform {
  cloud {
    organization = "sami-group"
    workspaces {
      name = "homelab-flux"
    }
  }
  required_providers {
    flux = {
      source  = "fluxcd/flux"
    }
  }
}

variable "gitlab_owner" {
  description = "gitlab owner"
  type        = string
  default     = "th3cookie"
}

variable "gitlab_token" {
  description = "gitlab token"
  type        = string
  sensitive   = true
}

variable "repository_url" {
  description = "gitlab repository url"
  type        = string
  default     = "https://gitlab.com/sami-group/homelab"
}

variable "target_path" {
  description = "flux sync target path"
  type        = string
  default     = "clusters/home"
}

provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url    = var.repository_url
    http = {
      username = var.gitlab_owner
      password = var.gitlab_token
    }
  }
}

resource "flux_bootstrap_git" "fluxing" {
  path   = var.target_path
  components_extra = [
    "image-reflector-controller",
    "image-automation-controller",
  ]
}
