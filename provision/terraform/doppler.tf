# Retrieve all secrets in the config.
data "doppler_secrets" "doppler_secrets" {
  project = var.doppler_project
  config = var.doppler_config
}
