#!/bin/bash
green=`tput setaf 2`
reset=`tput sgr0`
declare -a FILES
FILES=(group_vars/all vars/default_config.yml inventory)
for FILE in "${FILES[@]}"; do
    echo -e "\n${green}Variables in '${FILE}':${reset}\n"
    grep -v "^ *\(---\|#\)" "${FILE}"
done
