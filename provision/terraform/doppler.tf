provider "doppler" {
  # Token can be provided with the environment variable `TF_VAR_doppler_token` instead
  doppler_token = var.doppler_token
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

# doppler secrets resource - required
data "doppler_secrets" "doppler_secrets" {
  project = var.doppler_project
  config = var.doppler_config
}
