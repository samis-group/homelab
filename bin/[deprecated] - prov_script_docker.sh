#!/bin/bash
# DEPRECATED, this is what I was using before converting to ansible. Leaving here for reference to build playbook.

# If no sudo - quit
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   echo "Please call it with --> sudo $0"
   exit 1
fi

if [ $SUDO_USER ]; then
    REAL_USER=$SUDO_USER
else
    REAL_USER=$(whoami)
fi

read -p "Is this the correct docker user on the system: ${REAL_USER}? [Y/y] " ACTION

if [[ ! ${ACTION} =~ ^[Yy]$ ]]; then
    echo -e "List of users on the system:\n"
    awk -F: '{print $1}' /etc/passwd
    echo ""
    read -p "Which user will be running the docker containers? " REAL_USER
fi

# Getting things ready
if [[ ! $(lsb_release -is | grep -i ubuntu) ]]
then
    echo "This script will only work on an ubuntu machine."
    exit 1
fi
if [[ -x $(which apt) ]]; then
    INSTALL_COMMAND=$(which apt)
    echo -e "\nI have found your package manager '${INSTALL_COMMAND}'. Continuing...\n"
elif [[ -x $(which apt-get) ]]; then
    INSTALL_COMMAND=$(which apt-get)
    echo -e "\nI have found your package manager '${INSTALL_COMMAND}'. Continuing...\n"
else
    echo -e "\nI could not find your package manager, something went wrong, exiting.\n"
    exit 1
fi

# This is a menu creation function with an undefined amount of arguments passed to it.
menu_from_array () {
    select item; do
        # Check the selected menu item number
        if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $# ]; then
            echo "The selected item is $item"
            SELECTED_ITEM=$item
            break;
        else
            echo "Wrong selection: Select any number from 1-$#"
        fi
    done
}

# Read user input and store in variables
read -p 'Please set your computer hostname (Leave empty to skip): ' PC_HOSTNAME
if [[ -n ${PC_HOSTNAME} ]]; then
    hostnamectl set-hostname ${PC_HOSTNAME}
fi

# read -p "Would you like your MariaDB root password generated automatically? Otherwise, type the MySQL password: [Yy|Password] " MYSQL_ROOT_PASSWORD
# if [[ ${MYSQL_ROOT_PASSWORD} =~ ^[Yy]$ ]]; then
#     MYSQL_ROOT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 12)
# fi

# Comment the below if the user is different
# NAS_USER=admin
if [[ -z ${NAS_USER} ]]; then
    read -p 'NAS Username: ' NAS_USER
fi
read -p 'NAS Password: ' NAS_PASS
read 'NAS IP Address: ' NAS_IP
echo ''

read -p '.htpasswd Username: ' HTPASSWD_USER
read -p '.htpasswd Password: ' HTPASSWD_PASS
# read -p 'Cloudflare API token (Bitwarden cf-ddns): ' CLOUDFLARE_API_TOKEN
read -p 'Cloudflare API Key (Bitwarden): ' CLOUDFLARE_API_KEY
read -p 'Cloudflare Email: ' CLOUDFLARE_EMAIL
read -p 'Your domain (e.g. domain.com): ' DOMAIN_NAME
read -p 'Your gmail account to send alerts from this PC (e.g. blah@gmail.com): ' EMAIL_ADDRESS
echo -e "\nThis next one is the app password in the email account custom field in bitwarden and can be generated from here -> https://myaccount.google.com/apppasswords"
read -sp 'Your gmail app password for said email address: ' EMAIL_PASSWORD
echo "EMAIL_ADDRESS=${EMAIL_ADDRESS}" > ${DOCKERDIR}/scripts/email_conf.sh
echo "EMAIL_PASSWORD=${EMAIL_PASSWORD}" >> ${DOCKERDIR}/scripts/email_conf.sh

# Setting up the menu of interface on the machine to allow the user to specify which interface to allow local traffic to transmission on.
# Declare the array and add the interfaces to it
INTERFACE_OPTIONS=()
for i in $(ip a | grep -oP "(?<=\d: )(.*)(?=:)"); do
    IP=$(ip -4 a show ${i} | grep -oP '(?<=inet\s)\d+(\.\d+){3}\/\d+')
    INTERFACE_OPTIONS=( "${INTERFACE_OPTIONS[@]}" "${i} -> ${IP}" )
done
# Call the subroutine to create the menu
echo -e "\nPlease specify the subnet which transmission will allow local connections to the webui from (i.e. which network should transmission allow to bypass the VPN tunnel interface inside the container)?"
echo "This is generally the interface which has your devices private NAT IP from your router (e.g. 10.0.0.7 or 192.168.0.7 etc.)"
echo "Unfortunately, this script will only work on /24 subnets. No logic has been done on any other subnet."
menu_from_array "${INTERFACE_OPTIONS[@]}"
# LOCAL_INTERFACE=$(echo "${SELECTED_ITEM}" | awk '{print $1}')
LOCAL_NETWORK=$(echo "${SELECTED_ITEM}" | awk '{print $3}' | awk -F. '{print $1"."$2"."$3".0/24"}')
SERVER_IP=$(echo "${SELECTED_ITEM}" | awk '{print $3}' | grep -oP '\d+(\.\d+){3}')
TRANSMISSION_WHITELIST=$(echo "${LOCAL_NETWORK}" | awk -F. '{print "\"127.0.0.1,"$1"."$2"."$3".*\""}')

sudo $INSTALL_COMMAND update
sudo $INSTALL_COMMAND upgrade -y
sudo $INSTALL_COMMAND install -y cifs-utils bash-completion vim curl wget telnet cifs-utils nfs-common apt-transport-https \
ca-certificates software-properties-common jq python3.8 python3-pip git apache2-utils
# Determine Python version to parse yaml and add to MOTD. If no python, exit.
PY_VERSION=$(which python3.8)
if [[ -z ${PY_VERSION} ]]; then
    PY_VERSION=$(which python3.6)
fi
if [[ -z ${PY_VERSION} ]]; then
    PY_VERSION=$(which python3)
fi
if [[ -z ${PY_VERSION} ]]; then
    echo "Could not find your python version from either '3.8', '3.6' or '3'. Please manually install one of these with \"${INSTALL_COMMAND} install -y python3\"."
    echo "Exiting the script, please re-run it after installing python 3."
    exit 1
fi
sudo pip3 install -U pip
sudo pip3 install pyyaml
sudo pip3 install -U pyyaml
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo $INSTALL_COMMAND update
sudo $INSTALL_COMMAND install -y docker-ce
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq '.name' | sed 's/"//g')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo usermod -aG docker ${REAL_USER}
UID=$(id -u ${REAL_USER})
GID=$(grep docker /etc/group | grep -oP "\d+")
TZ="Australia/Sydney"
USERDIR="/home/${REAL_USER}"
DOCKERDIR="${USERDIR}/docker"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Removing the local DNS resolver from binding to port 53 so pihole can do this DNS instead (not running pihole in docker yet)
# echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
# systemctl restart systemd-resolved.service

# Creating dir structure and properties
mkdir -p ${USERDIR}/mount/{downloads,video,docker_backups} ${DOCKERDIR}/shared/{plexms,radarr/MediaCover,sonarr/MediaCover} ${DOCKERDIR}/traefik ${DOCKERDIR}/secrets

# Creating the files
cp -vR $SCRIPT_DIR/DOCKERDIR/* ${DOCKERDIR}/
sudo find ${DOCKERDIR}/ -name testfile -exec rm -f {} +
htpasswd -cb ${DOCKERDIR}/secrets/htpasswd ${HTPASSWD_USER} ${HTPASSWD_PASS}
# echo $CLOUDFLARE_API_TOKEN > ${DOCKERDIR}/secrets/cloudflare_api_token
echo $CLOUDFLARE_API_KEY > ${DOCKERDIR}/secrets/cloudflare_api_key
echo $CLOUDFLARE_EMAIL > ${DOCKERDIR}/secrets/cloudflare_email

cat << EOF | sudo tee -a /etc/fstab

# Custom ones

${NAS_IP}:/volume1/downloads ${USERDIR}/mount/downloads nfs rsize=8192,wsize=8192,timeo=14,intr
${NAS_IP}:/volume1/video ${USERDIR}/mount/video nfs rsize=8192,wsize=8192,timeo=14,intr
${NAS_IP}:/volume1/computer_stuff/docker_backups ${USERDIR}/mount/docker_backups nfs rsize=8192,wsize=8192,timeo=14,intr
EOF

##############
### Others ###
##############

# Run the parse-yaml script to create the directory structure of all services in the docker-compose.yml
chmod +x ${DOCKERDIR}/scripts/parse-yaml.py
sudo ${PY_VERSION} ${DOCKERDIR}/scripts/parse-yaml.py

# Final touches
[[ -e $SCRIPT_DIR/docker-compose.yml ]] && ln -s $SCRIPT_DIR/docker-compose.yml ${DOCKERDIR}/docker-compose.yml
[[ -e $SCRIPT_DIR/docker-compose-dev.yml ]] && ln -s $SCRIPT_DIR/docker-compose-dev.yml ${DOCKERDIR}/docker-compose-dev.yml
sudo chmod 775 ${DOCKERDIR}
sudo chmod 600 ${DOCKERDIR}/traefik/acme/acme.json
sudo chown -R ${REAL_USER}:${REAL_USER} ${DOCKERDIR}/
sudo setfacl -Rdm g:docker:rwx ${DOCKERDIR}
sed -i "/HostHeader/ s/domain.com/${DOMAIN_NAME}/g" ${DOCKERDIR}/traefik/rules/*

cat << EOF | sudo tee -a /etc/crontab

0 4 * * * ${REAL_USER} cd ${DOCKERDIR}; /usr/local/bin/docker-compose pull; /usr/local/bin/docker-compose up -d --remove-orphans
@reboot ${REAL_USER} cd ${DOCKERDIR}; /usr/local/bin/docker-compose up -d
0 3 * * * ${REAL_USER} /usr/bin/docker system prune -af --filter "until=$((7*24))h"
0 3 * * THU ${REAL_USER} ${DOCKERDIR}/scripts/docker-backup.sh
*/10 * * * * root if [ \$(grep '/home/${REAL_USER}/mount/' /proc/mounts | wc -l) -lt 3 ]; then mount -a && logger "mounted NAS"; fi

EOF

echo -e "Here are some values that you need to populate in your .env file:\n"
echo "UID=${UID}"
echo "GID (this is the docker group GID not the user you login with)=${GID}"
echo "TZ=${TZ}"
echo "USERDIR=${USERDIR}"
echo "DOCKERDIR=${DOCKERDIR}"
echo "LOCAL_NETWORK=${LOCAL_NETWORK}"
echo "SERVER_IP=${SERVER_IP}"
[[ $(which openssl) ]] && echo "OAUTH_SECRET (auto generated)=$(openssl rand -hex 16)"

echo -e "\nDON'T FORGET TO LOGOUT AND LOGIN FOR YOUR USER TO BE ADDED TO THE DOCKER GROUP IN A NEW SHELL! \n"
# echo -e "Also: Add your openvpn config and creds files in your container location:\n${DOCKERDIR}/qbittorrent/openvpn \n"
# echo -e "Hint, yours are in: Samis_Folder/ops/docker_prov on the nas... \n"
# echo "rsync -zPvh admin@${NAS_IP}:/volume1/Samis_Folder/ops/docker_prov/au491.nordvpn.com.tcp443.ovpn /home/sami/docker/qbittorrent/openvpn/"
# echo "rsync -zPvh admin@${NAS_IP}:/volume1/Samis_Folder/ops/docker_prov/credentials.conf /home/sami/docker/qbittorrent/openvpn/"
echo -e "\nPlease fill in your secrets located in ${DOCKERDIR}/secrets/\n"
# echo -e "\nPlease also fill your domain in the custom traefik rules located in ${DOCKERDIR}/traefik/rules/\n"
[[ ! $(which openssl) ]] && echo "PLEASE INSTALL OPENSSL AND RUN THE FOLLOWING COMMAND MANUALLY:" && echo -e "echo \$(openssl rand -hex 16) > \${DOCKERDIR}/secrets/oauth_secret\n"
echo -e "\nIf you experience any perms issues, chown the docker dir recursively with:\nsudo chown -R ${REAL_USER}:${REAL_USER} ${DOCKERDIR}/\n"
