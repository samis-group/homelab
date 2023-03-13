terraform {
  cloud {
    organization = "sami-group"
    workspaces {
      name = "homelab-doppler"
    }
  }
  required_providers {
    doppler = {
      source = "DopplerHQ/doppler"
    }
  }
}

variable "doppler_token" {
  description = "A token to authenticate with Doppler"
  type        = string
}

variable "doppler_project" {
  description = "Doppler Project Name"
  type        = string
  default     = "homelab"
}

variable "doppler_config" {
  description = "Doppler Config Name"
  type        = string
  default     = "dev_container"
}

# The provider must always be specified with authentication
provider "doppler" {
  # Your Doppler token, either a personal or service token
  doppler_token = var.doppler_token
  # The token can be provided with the environment variable `TF_VAR_doppler_token` instead of input
}

# Mapped access to secrets
data "doppler_secrets" "doppler_secrets" {
  # Project and config are required if you are using a personal token
  project = var.doppler_project
  config = var.doppler_config
}

# output "all_secrets" {
#   # nonsensitive used for demo purposes only
#   value = nonsensitive(data.doppler_secrets.doppler_secrets.map)
# }

# output "domain_name" {
#   # Individual keys can be accessed directly by name
#   value = nonsensitive(data.doppler_secrets.doppler_secrets.map.DOMAIN_NAME)
# }

# output "vm_netmask" {
#   # Use `tonumber` and `tobool` to parse string values into Terraform primatives
#   value = nonsensitive(tonumber(data.doppler_secrets.doppler_secrets.map.VM_NETMASK))
# }

# output "json_parsing_values" {
#   # JSON values can be decoded direcly in Terraform
#   # e.g. FEATURE_FLAGS = `{ "AUTOPILOT": true, "TOP_SPEED": 130 }`
#   value = nonsensitive(jsondecode(data.doppler_secrets.doppler_secrets.map.TEST_JSON_DATA)["test"])
# }
