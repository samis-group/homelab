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
