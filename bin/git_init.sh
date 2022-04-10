#!/bin/bash
# sets up a pre-commit hook to ensure that vault.yaml is encrypted
#
# credit goes to nick busey from homelabos for this neat little trick
# https://gitlab.com/NickBusey/HomelabOS/-/issues/355

if [ -d .git/ ]; then
    cat <<EOT > .git/hooks/pre-commit
#!/bin/bash
#######################################
### THIS FILE IS MANAGED BY ANSIBLE ###
###    PLEASE MAKE CHANGES THERE    ###
#######################################

red=\`tput setaf 1\`
green=\`tput setaf 2\`
reset=\`tput sgr0\`
# Check group_vars and inventory files to ensure they're encrypted
if ( grep -q "\$ANSIBLE_VAULT;" group_vars/all.yml ) && ( grep -q "\$ANSIBLE_VAULT;" inventory ); then
echo "\${green}Vaults are encrypted. Safe to commit.\${reset}"
else
echo -e "\${red}Vaults are not encrypted! Run:\${reset}"
echo -e "make encrypt\${red}\nAND\n\${reset}git add .\n\${red}and try again.\${reset}"
exit 1
fi
# Check file that needs to be encrypted.
FILE_TO_CHECK="docker_vm_vars.yml"
if [ -e "\${FILE_TO_CHECK}" ]; then
echo "checking to ensure file '\${FILE_TO_CHECK}' is encrypted"
if ( grep -q "\$ANSIBLE_VAULT;" \${FILE_TO_CHECK} ); then
echo "\${green}\${FILE_TO_CHECK} is encrypted. Safe to commit.\${reset}"
else
echo -e "\${red}\${FILE_TO_CHECK} is not encrypted! Run:\${reset}"
echo -e "make encrypt\${red}\nAND\n\${reset}git add .\n\${red}and try again.\${reset}"
exit 1
fi
fi
EOT

fi

chmod +x .git/hooks/pre-commit
