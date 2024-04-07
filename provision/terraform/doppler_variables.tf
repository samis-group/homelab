variable "doppler_token" {
  description = "A token to authenticate with Doppler"
  type        = string
  sensitive   = true
}

variable "kubeconfig_file" {
  description = "The kubeconfig file to use for deploying these resources to said cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_ca_cert" {
  description = "The kubernetes cluster CA Cert in base64 encoding (grab from kubeconfig)"
  type        = string
}

variable "kube_client_cert" {
  description = "The kubernetes cluster CA Cert in base64 encoding (grab from kubeconfig)"
  type        = string
}

variable "kube_client_key" {
  description = "The kubernetes cluster CA Cert in base64 encoding (grab from kubeconfig)"
  type        = string
}

variable "doppler_project" {
  description = "Doppler Project Name"
  type        = string
  default     = "homelab"
}

variable "doppler_config" {
  description = "Doppler Config Name"
  type        = string
  default     = "dev_container"
}
