#!/bin/bash
#######################################
### THIS FILE IS MANAGED BY ANSIBLE ###
###    PLEASE MAKE CHANGES THERE    ###
#######################################

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
FILES_TO_CHECK="group_vars/all/vault inventory/hosts.ini"
for FILE_PROCESSING in $FILES_TO_CHECK; do
  # Ensure it exists first
  if [ -e "$FILE_PROCESSING" ]; then
    echo "checking to ensure file '${FILE_PROCESSING}' is encrypted..."
    # Check vault file to ensure it's encrypted
    if ( grep -q '$ANSIBLE_VAULT;' ${FILE_PROCESSING} ); then
      echo "${green}$FILE_PROCESSING is encrypted.${reset}"
    else
      echo -e "${red}$FILE_PROCESSING is not encrypted! Run:${reset}"
      echo -e "make encrypt${red}\nAND\n${reset}git add .\n${red}and try again.${reset}"
      # exit 1
    fi
  else
    echo "File ${FILE_PROCESSING} does not exist"
  fi
done
