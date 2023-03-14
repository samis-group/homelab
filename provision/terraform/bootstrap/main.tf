terraform {
  # Get a local statefile first, by commenting this cloud key out. Put back in after bootstrap successful
  # Now migrate state to it -> https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-migrate
  cloud {
    organization = "sami-group"
    workspaces {
      name = "bootstrap"
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
