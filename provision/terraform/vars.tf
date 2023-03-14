# https://registry.terraform.io/providers/fluxcd/flux/latest/docs
variable "gitlab_owner" {
  description = "gitlab owner"
  type        = string
  default     = "th3cookie"
}

# Figure out how to reference doppler secrets from inside this module
variable "gitlab_personal_access_token" {
  description = "gitlab token"
  type        = string
  sensitive   = true
}

variable "repository_url" {
  description = "gitlab repository url"
  type        = string
  default     = "https://gitlab.com/sami-group/homelab"
}

variable "target_path" {
  description = "flux sync target path"
  type        = string
  default     = "clusters/home"
}

variable "doppler_token" {
  description = "A token to authenticate with Doppler"
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
