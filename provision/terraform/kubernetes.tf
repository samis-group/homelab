provider "kubernetes" {
  config_path = var.kubeconfig_file
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

# Gitlab Registry Credentials for pulling private images
resource "kubernetes_secret" "github_registry_credentials" {
  metadata {
    name      = "github-registry-credentials"
    namespace = "default"
  }
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://ghcr.io" = {
          username = data.doppler_secrets.dev_container.map.GITHUB_USERNAME
          password = data.doppler_secrets.dev_container.map.GITHUB_READ_PACKAGES_TOKEN
          email    = data.doppler_secrets.dev_container.map.GMAIL_ADDRESS
          auth     = base64encode("${data.doppler_secrets.dev_container.map.GITHUB_USERNAME}:${data.doppler_secrets.dev_container.map.GITHUB_READ_PACKAGES_TOKEN}")
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
}
