# output "doppler_token2" {
#   # Access the raw secret value
#   value = nonsensitive(doppler_secret.doppler_token.value)
# }

# output "doppler_token" {
#   # Access the computed secret value (if using Doppler secrets referencing)
#   value = doppler_service_token.doppler_token.key
#   sensitive = true
# }

# output "doppler_gitlab_token" {
#   # Access the computed secret value (if using Doppler secrets referencing)
#   value = doppler_service_token.doppler_gitlab_token.key
#   sensitive = true
# }

# output "all_secrets" {
#   # nonsensitive used for demo purposes only
#   value = nonsensitive(data.doppler_secrets.doppler_secrets.map)
# }

# output "domain_name" {
#   # Individual keys can be accessed directly by name
#   value = nonsensitive(data.doppler_secrets.doppler_secrets.map.DOMAIN_NAME)
# }

# output "vm_netmask" {
#   # Use `tonumber` and `tobool` to parse string values into Terraform primatives
#   value = nonsensitive(tonumber(data.doppler_secrets.doppler_secrets.map.VM_NETMASK))
# }

# output "json_parsing_values" {
#   # JSON values can be decoded direcly in Terraform
#   # e.g. FEATURE_FLAGS = `{ "AUTOPILOT": true, "TOP_SPEED": 130 }`
#   value = nonsensitive(jsondecode(data.doppler_secrets.doppler_secrets.map.TEST_JSON_DATA)["test"])
# }
