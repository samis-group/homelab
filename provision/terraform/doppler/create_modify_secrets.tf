### Create and modify Doppler secrets with the `doppler_secret` resource

# resource "random_password" "db_password" {
#   length = 32
#   special = true
# }

# resource "doppler_secret" "db_password" {
#   project = var.doppler_project
#   config = var.doppler_config
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
