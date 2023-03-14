provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Doppler token to k3s cluster
resource "kubernetes_secret" "doppler_kube_token" {
  metadata {
    name = "doppler-token"
    namespace = "doppler-operator-system"
  }
  data = {
    serviceToken = doppler_service_token.doppler_token.key
  }
  type = "Opaque"
}

# Discord webhook needs to be its own secret with `address` key for alerts
resource "kubernetes_secret" "discord_webhook" {
  metadata {
    name = "discord-webhook"
    namespace = "default"
  }
  data = {
    address = base64encode(data.doppler_secrets.doppler_secrets.map.DISCORD_FLUX_WEBHOOK_URL)
  }
  type = "Opaque"
}
