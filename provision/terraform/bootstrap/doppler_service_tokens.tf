# Create a doppler service token inside our project
resource "doppler_service_token" "doppler_token_auth_api" {
  project = var.doppler_project
  config = var.doppler_config
  name = "doppler_token_auth_api"
  access = "read/write"
}

# Set secret DOPPLER_TOKEN in doppler
resource "doppler_secret" "doppler_token_auth_api" {
  project = var.doppler_project
  config = var.doppler_config
  name = "DOPPLER_TOKEN_AUTH_API"
  value = doppler_service_token.doppler_token_auth_api.key
}

# # Create a doppler service token inside our project
# resource "doppler_service_token" "doppler_gitlab_token" {
#   project = var.doppler_project
#   config = "ci"
#   name = "doppler_gitlab_token"
#   access = "read/write"
# }

# # Set secret DOPPLER_GITLAB_TOKEN in doppler dev_container config
# resource "doppler_secret" "doppler_gitlab_token_dev_container" {
#   project = var.doppler_project
#   config = var.doppler_config
#   name = "DOPPLER_GITLAB_TOKEN"
#   value = doppler_service_token.doppler_gitlab_token.key
# }

# # Set secret DOPPLER_GITLAB_TOKEN in doppler ci config
# resource "doppler_secret" "doppler_gitlab_token_ci" {
#   project = var.doppler_project
#   config = "ci"
#   name = "DOPPLER_GITLAB_TOKEN"
#   value = doppler_service_token.doppler_gitlab_token.key
# }
