# provider "flux" {
#   kubernetes = {
#     config_path = "~/.kube/config"
#   }
#   git = {
#     url    = var.repository_url
#     http = {
#       username = var.gitlab_owner
#       password = var.gitlab_personal_access_token
#     }
#   }
# }

# resource "flux_bootstrap_git" "fluxing" {
#   path   = var.target_path
#   components_extra = [
#     "image-reflector-controller",
#     "image-automation-controller",
#   ]
# }
