#!/bin/bash
#######################################
### THIS FILE IS MANAGED BY ANSIBLE ###
###    PLEASE MAKE CHANGES THERE    ###
#######################################

red=\`tput setaf 1\`
green=\`tput setaf 2\`
reset=\`tput sgr0\`
# Check vault file to ensure it's encrypted
if ( grep -q '\$ANSIBLE_VAULT;' vars/vault.yml ); then
  echo "\${green}Vault is encrypted. Safe to commit.\${reset}"
else
  echo -e "\${red}Vault is not encrypted! Run:\${reset}"
  echo -e "make encrypt\${red}\nAND\n\${reset}git add .\n\${red}and try again.\${reset}"
  exit 1
fi
# Check additional file that needs to be encrypted (optional).
# FILE_TO_CHECK="docker_vm_vars.yml"
# if [ -e '\${FILE_TO_CHECK}' ]; then
#   echo "checking to ensure file '\${FILE_TO_CHECK}' is encrypted"
#   if ( grep -q '\$ANSIBLE_VAULT;' \${FILE_TO_CHECK} ); then
#     echo "\${green}\${FILE_TO_CHECK} is encrypted. Safe to commit.\${reset}"
#   else
#     echo -e "\${red}\${FILE_TO_CHECK} is not encrypted! Run:\${reset}"
#     echo -e "make encrypt\${red}\nAND\n\${reset}git add .\n\${red}and try again.\${reset}"
#     exit 1
#   fi
# fi
