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

# Stop all containers so data doesn't change during backup
echo "Tearing down the stack..."
#docker stop $(docker ps -q)
dcdown all

echo -e "Subject: Docker Backups\n\nDocker backups status:\n" > ../scripts/mail.txt

# Check if it's mounted first
mountpoint -q ${USERDIR}/mount/docker_backups
if [[ $? -ne 0 ]]; then
    echo "docker backups folder not mounted, please investigate and fix." >> ../scripts/mail.txt
    source ../scripts/email.sh
    exit 1
else
    echo "docker_backups is mounted, continuing..."
fi

for i in *; do
    # If not dir or not one of items below, skip, else, tar it up and ship it.
    if [[ ! -d "${i}" ]] || [[ "${i}" =~ (shared|secrets|scripts|docs) ]]; then
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
dcpull all
dcuprem all

# Fire off email
source ../scripts/email.sh
