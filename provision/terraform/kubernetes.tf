# Doppler token to k3s cluster
resource "kubernetes_secret" "doppler_kube_token" {
  metadata {
    name = "doppler-token-auth-api"
    namespace = "doppler-operator-system"
  }
  data = {
    dopplerToken = data.doppler_secrets.doppler_secrets.map.DOPPLER_TOKEN
  }
}

# Discord webhook needs to be its own secret with `address` key for alerts
resource "kubernetes_secret" "discord_webhook" {
  metadata {
    name = "discord-webhook"
    namespace = "default"
  }
  data = {
    address = data.doppler_secrets.doppler_secrets.map.DISCORD_FLUX_WEBHOOK_URL
  }
}
