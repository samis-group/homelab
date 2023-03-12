terraform {
  required_providers {
    doppler = {
      # version = <latest version>
      source = "DopplerHQ/doppler"
    }
  }
}

###
### Setup the Doppler provider
###

variable "doppler_token" {
  description = "A token to authenticate with Doppler"
  type = string
}

# The provider must always be specified with authentication
provider "doppler" {
  # Your Doppler token, either a personal or service token
  doppler_token = var.doppler_token
  # The token can be provided with the environment variable `TF_VAR_doppler_token` instead of input
}

###
### Read Doppler secrets with the doppler_secrets data provider
###

# # Mapped access to secrets
# data "doppler_secrets" "this" {
#   # Project and config are required if you are using a personal token
#   project = "homelab"
#   config = "dev_container"
# }

# output "all_secrets" {
#   # nonsensitive used for demo purposes only
#   value = nonsensitive(data.doppler_secrets.this.map)
# }

# output "domain_name" {
#   # Individual keys can be accessed directly by name
#   value = nonsensitive(data.doppler_secrets.this.map.DOMAIN_NAME)
# }

# output "vm_netmask" {
#   # Use `tonumber` and `tobool` to parse string values into Terraform primatives
#   value = nonsensitive(tonumber(data.doppler_secrets.this.map.VM_NETMASK))
# }

# output "json_parsing_values" {
#   # JSON values can be decoded direcly in Terraform
#   # e.g. FEATURE_FLAGS = `{ "AUTOPILOT": true, "TOP_SPEED": 130 }`
#   value = nonsensitive(jsondecode(data.doppler_secrets.this.map.TEST_JSON_DATA)["test"])
# }

###
### Create and modify Doppler secrets with the `doppler_secret` resource
###

# resource "random_password" "db_password" {
#   length = 32
#   special = true
# }

# resource "doppler_secret" "db_password" {
#   project = "backend"
#   config = "dev"
#   name = "DB_PASSWORD"
#   value = random_password.db_password.result
# }

# output "resource_value" {
#   # Access the raw secret value
#   value = nonsensitive(doppler_secret.db_password.value)
# }

# output "resource_computed" {
#   # Access the computed secret value (if using Doppler secrets referencing)
#   value = nonsensitive(doppler_secret.db_password.computed)
# }

###
### Create and modify Doppler projects, environments, configs, and service tokens
###

# Create and manage your project
resource "doppler_project" "homelab" {
  name = "homelab"
  description = "Homelab Project"
}

# Create and manage your environments
resource "doppler_environment" "homelab_dev" {
  project = doppler_project.homelab.name
  slug = "dev"
  name = "Development"
}

resource "doppler_environment" "homelab_gitlab" {
  project = doppler_project.homelab.name
  slug = "gitlab"
  name = "Gitlab CI"
}

resource "doppler_environment" "homelab_production" {
  project = doppler_project.homelab.name
  slug = "prd"
  name = "Production"
}

# Create and manage branch configs
resource "doppler_config" "homelab_dev_container" {
  project = doppler_project.homelab.name
  environment = doppler_environment.homelab_dev.slug
  name = "dev_container"
}

resource "doppler_service_token" "homelab_dev_container_token" {
  project = doppler_project.homelab.name
  config = doppler_config.homelab_dev_container.name
  name = "test token"
  access = "read"
}

output "token_key" {
  # Access the service token key
  value = nonsensitive(doppler_service_token.homelab_dev_container_token.key)
}
