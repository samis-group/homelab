#!/bin/bash

#######################################
### THIS FILE IS MANAGED BY ANSIBLE ###
###    PLEASE MAKE CHANGES THERE    ###
#######################################

# Script to backup docker data

source {{docker_dir}}/.env
source ${USERDIR}/.bashrc.d/docker-aliases

# Jump into appdata dir containing container volume mounts lollers
cd ${DOCKERDIR}/appdata

sudo -u {{ main_user }} 'bash -ic "dcdown all"'

# Stop all containers so data doesn't change during backup
#docker stop $(docker ps -q)

echo -e "Subject: Docker Backups\n\nDocker backups status:\n" > ../scripts/mail.txt

# Check if it's mounted first
mountpoint -q ${USERDIR}/mount/docker_backups
if [[ $? -ne 0 ]]; then
    echo "docker backups folder not mounted, please investigate and fix." >> ../scripts/mail.txt
    source ../scripts/email.sh
    exit 1
fi

for i in *; do
    # If not dir or not one of list, skip, else, tar it up
    if [[ ! -d "${i}" ]] || [[ "${i}" =~ (shared|secrets|scripts) ]]; then
        continue
    else
        rm -f ${USERDIR}/mount/docker_backups/${i}.tar.gz
        run_backup=$(tar -czf ${USERDIR}/mount/docker_backups/${i}.tar.gz ${i} 2>&1)
        if [[ $? -eq 0 ]]; then
            echo "${i}: Success." >> ../scripts/mail.txt
        else
            echo -e "\n------------------------\n${i}: FAILED, please investigate...\n${run_backup}\n\n" >> ../scripts/mail.txt
        fi
    fi
done

# Pull latest images and start all
sudo -u {{ main_user }} 'bash -ic "dcpull all; dcuprem all"'

# Fire off email
source ../scripts/email.sh
