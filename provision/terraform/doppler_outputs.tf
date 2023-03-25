# output "doppler_secrets" {
#   # nonsensitive used for demo purposes only
#   value = nonsensitive(data.doppler_secrets.dev_container.map)
# }

# output "doppler_token2" {
#   # Access the raw secret value
#   value = nonsensitive(doppler_secret.doppler_token.value)
# }

# output "domain_name" {
#   # Individual keys can be accessed directly by name
#   value = nonsensitive(data.doppler_secrets.dev_container.map.DOMAIN_NAME)
# }

# output "vm_netmask" {
#   # Use `tonumber` and `tobool` to parse string values into Terraform primatives
#   value = nonsensitive(tonumber(data.doppler_secrets.dev_container.map.VM_NETMASK))
# }

# output "json_parsing_values" {
#   # JSON values can be decoded direcly in Terraform
#   # e.g. FEATURE_FLAGS = `{ "AUTOPILOT": true, "TOP_SPEED": 130 }`
#   value = nonsensitive(jsondecode(data.doppler_secrets.dev_container.map.TEST_JSON_DATA)["test"])
# }
