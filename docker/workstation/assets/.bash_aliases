### Aliases ###
alias ll='ls -alh'
alias t='task'
alias k='kubectl'
# Kubectl file operations
alias kcaf='doppler run -- kubectl apply -f '
alias kcdf='doppler run -- kubectl delete -f '
# Kubectl kustomize operations
alias kcak='doppler run -- kubectl apply -k '
alias kcdk='doppler run -- kubectl delete -k '

### Functions ###
# kcaf() {
#   local manifest_file="$1"

#   if [[ -z "$manifest_file" ]]; then
#     echo "Usage: kcaf <manifest_file>"
#     return 1
#   fi

#   # Run Doppler to substitute environment variables and apply manifest
#   doppler run -- envsubst < "$manifest_file" | kubectl apply -f -
# }
# kcdf() {
#   local manifest_file="$1"

#   if [[ -z "$manifest_file" ]]; then
#     echo "Usage: kcdf <manifest_file>"
#     return 1
#   fi

#   # Run Doppler to substitute environment variables and apply manifest
#   doppler run -- envsubst < "$manifest_file" | kubectl delete -f -
# }
