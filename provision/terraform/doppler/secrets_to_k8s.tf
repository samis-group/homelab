provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "kubernetes_secret" "doppler_kube_token" {
  metadata {
    name = "doppler-token-secret"
    namespace = "doppler-operator-system"
  }
}

# Create a doppler service token inside our project
resource "doppler_service_token" "homelab_dev_container_token" {
  project = var.doppler_project
  config = var.doppler_config
  name = "k3s-cluster-doppler-operator"
  access = "read"
}

# Apply token to k3s cluster
resource "kubernetes_secret" "doppler_kube_token" {
  metadata {
    name = "doppler-token-secret"
    namespace = "doppler-operator-system"
  }
  data = {
    serviceToken = doppler_service_token.homelab_dev_container_token.key
  }
  type = "Opaque"
}

# Discord webhook needs to be its own secret with `address` key
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
