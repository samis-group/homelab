#!/bin/bash

#######################################
### THIS FILE IS MANAGED BY ANSIBLE ###
###    PLEASE MAKE CHANGES THERE    ###
#######################################

source "${HOME}/docker/.env"

curl --ssl-reqd \
  --url 'smtps://smtp.gmail.com:465' \
  --user "${GMAIL_ADDRESS}:${GMAIL_APP_PASS}" \
  --mail-from "${GMAIL_ADDRESS}" \
  --mail-rcpt "${GMAIL_ADDRESS}" \
  --upload-file "${DOCKERDIR}/scripts/mail.txt"
