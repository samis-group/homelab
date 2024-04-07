provider "kubernetes" {
  # config_path = var.kubeconfig_file
  ##############################################################
  ### Use below alternative config method - Change as needed ###
  ##############################################################
  host                   = var.kube_host
  cluster_ca_certificate = base64decode(var.kube_ca_cert)     # yq eval '.clusters[].cluster.certificate-authority-data' /home/ubuntu/.kube/config
  client_certificate     = base64decode(var.kube_client_cert) # yq eval '.users[0].user.client-certificate-data' /home/ubuntu/.kube/config
  client_key             = base64decode(var.kube_client_key)  # yq eval '.users[0].user.client-key-data' /home/ubuntu/.kube/config
  ignore_labels          = [
    "kustomize.toolkit.fluxcd.io/name",
    "kustomize.toolkit.fluxcd.io/namespace",
    "kustomize.toolkit.fluxcd.io/prune"
  ]
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

# Github Registry Credentials for pulling private images
resource "kubernetes_secret" "github_registry_credentials-default" {
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

resource "kubernetes_namespace" "actions-runner-system" {
  metadata {
    name = "actions-runner-system"
  }
}

# Github Registry Credentials for pulling private images
resource "kubernetes_secret" "github_registry_credentials-actions-runner-system" {
  metadata {
    name      = "github-registry-credentials"
    namespace = "actions-runner-system"
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
