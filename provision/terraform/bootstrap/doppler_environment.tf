#################
# project - K3s #
#################
resource "doppler_project" "k3s" {
  name = var.doppler_project_k3s
  description = "Homelab Project"
}

resource "doppler_environment" "k3s_dev" {
  project = doppler_project.k3s.name
  slug = "dev"
  name = "Development"
}

resource "doppler_environment" "k3s_gitlab" {
  project = doppler_project.k3s.name
  slug = "ci"
  name = "Gitlab CI"
}

resource "doppler_environment" "k3s_production" {
  project = doppler_project.k3s.name
  slug = "prod"
  name = "Production"
}

resource "doppler_config" "k3s_dev_container" {
  project = doppler_project.k3s.name
  environment = doppler_environment.k3s_dev.slug
  name = var.doppler_config
}

#####################
# project - Homelab #
#####################
resource "doppler_project" "homelab" {
  name = var.doppler_project
  description = "Homelab Project"
}

resource "doppler_environment" "homelab_dev" {
  project = doppler_project.homelab.name
  slug = "dev"
  name = "Development"
}

resource "doppler_environment" "homelab_gitlab" {
  project = doppler_project.homelab.name
  slug = "ci"
  name = "Gitlab CI"
}

resource "doppler_environment" "homelab_production" {
  project = doppler_project.homelab.name
  slug = "prod"
  name = "Production"
}

resource "doppler_config" "homelab_dev_container" {
  project = doppler_project.homelab.name
  environment = doppler_environment.homelab_dev.slug
  name = var.doppler_config
}

############################
# project - Homelab_backup #
############################
resource "doppler_project" "homelab_backup" {
  name = var.doppler_project_backup
  description = "Homelab Backup Project"
}

resource "doppler_environment" "homelab_backup_dev" {
  project = doppler_project.homelab_backup.name
  slug = "dev"
  name = "Development"
}

resource "doppler_environment" "homelab_backup_gitlab" {
  project = doppler_project.homelab_backup.name
  slug = "ci"
  name = "Gitlab CI"
}

resource "doppler_environment" "homelab_backup_production" {
  project = doppler_project.homelab_backup.name
  slug = "prod"
  name = "Production"
}

resource "doppler_config" "homelab_backup_dev_container" {
  project = doppler_project.homelab_backup.name
  environment = doppler_environment.homelab_backup_dev.slug
  name = var.doppler_config
}
