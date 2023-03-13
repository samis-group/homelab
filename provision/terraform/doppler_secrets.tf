# Set secret doppler_token to doppler API
resource "doppler_secret" "doppler_token" {
  project = var.doppler_project
  config = var.doppler_config
  name = "DOPPLER_TOKEN"
  value = var.doppler_token
}
