provider "doppler" {
  # Token can be provided with the environment variable `TF_VAR_doppler_token` instead
  doppler_token = var.doppler_token
}

# doppler secrets resource - required
data "doppler_secrets" "doppler_secrets" {
  project = var.doppler_project
  config = var.doppler_config
}
