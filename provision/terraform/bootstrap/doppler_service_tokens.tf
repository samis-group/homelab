# Create a doppler service token inside our project
resource "doppler_service_token" "doppler_token" {
  project = var.doppler_project
  config = var.doppler_config
  name = "doppler_token"
  access = "read/write"
}

# Create a doppler service token inside our project
resource "doppler_service_token" "doppler_gitlab_token" {
  project = var.doppler_project
  config = var.doppler_config
  name = "doppler_gitlab_token"
  access = "read/write"
}

# Set secret DOPPLER_TOKEN in doppler
resource "doppler_secret" "doppler_token" {
  project = var.doppler_project
  config = var.doppler_config
  name = "DOPPLER_TOKEN"
  value = doppler_service_token.doppler_token.key
}

# Set secret DOPPLER_GITLAB_TOKEN in doppler
resource "doppler_secret" "doppler_gitlab_token" {
  project = var.doppler_project
  config = var.doppler_config
  name = "DOPPLER_GITLAB_TOKEN"
  value = doppler_service_token.doppler_gitlab_token.key
}
