variable "doppler_token" {
  description = "A token to authenticate with Doppler"
  type        = string
  sensitive   = true
}

variable "doppler_project" {
  description = "Doppler Project Name"
  type        = string
  default     = "homelab"
}

variable "doppler_project_backup" {
  description = "Doppler Project Name"
  type        = string
  default     = "homelab_backup"
}

variable "doppler_config" {
  description = "Doppler Config Name"
  type        = string
  default     = "dev_container"
}
