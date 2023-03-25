provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Doppler token to k3s cluster
resource "kubernetes_secret" "doppler_token_auth_api" {
  metadata {
    name = "doppler-token-auth-api"
    namespace = "kube-system"
  }
  data = {
    dopplerToken = data.doppler_secrets.dev_container.map.DOPPLER_TOKEN_AUTH_API
  }
}

# Discord webhook needs to be its own secret with `address` key for alerts
resource "kubernetes_secret" "discord_webhook" {
  metadata {
    name = "discord-webhook"
    namespace = "kube-system"
  }
  data = {
    address = data.doppler_secrets.dev_container.map.DISCORD_FLUX_WEBHOOK_URL
  }
}
