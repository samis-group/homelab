provider "doppler" {
  # Token can be provided with the environment variable `TF_VAR_doppler_token` instead
  doppler_token = var.doppler_token
}

# Retrieve all secrets in the config.
data "doppler_secrets" "dev_container" {
  project = var.doppler_project
  config = var.doppler_config
}
