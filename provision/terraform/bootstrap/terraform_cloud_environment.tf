resource "tfe_organization" "sami-group" {
  name  = "sami-group"
  email = "th3cookie@gmail.com"
}

resource "tfe_workspace" "terraform" {
  name         = "terraform"
  description  = "Terraform Automations"
  organization = tfe_organization.sami-group.name
  tag_names    = ["terraform"]
  execution_mode = "local"
}

resource "tfe_workspace" "bootstrap" {
  name         = "bootstrap"
  description  = "Bootstraping workspace separate to automations as it creates itself"
  organization = tfe_organization.sami-group.name
  tag_names    = ["bootstrap"]
  execution_mode = "local"
}

resource "tfe_workspace" "post-tasks" {
  name         = "post-tasks"
  description  = "post-tasks workspace to separate post tasks due to Namespace conflicts when flux adds it's stuff"
  organization = tfe_organization.sami-group.name
  tag_names    = ["post-tasks"]
  execution_mode = "local"
}
