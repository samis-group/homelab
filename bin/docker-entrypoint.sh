#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

# Set the user and group IDs at container runtime based on host system
# This will allow us to mount content from our FS without perms issues inside the container
echo "usermod -u ${USER_ID} ${USER_NAME}"
usermod -u ${USER_ID} ${USER_NAME}
# echo "groupmod -u ${GROUP_ID} ${USER_NAME}"
# groupmod -g ${GROUP_ID} ${USER_NAME}

# Aliases
gosu ${USER_NAME} echo "alias ll='ls -alh'" >> /home/${USER_NAME}/.bashrc

# Start SSH inside entrypoint for ansible tasks delegated to localhost (container)
echo "Starting sshd..."
service ssh start > /dev/null

echo "Setting git safe dir..."
gosu ${USER_NAME} git config --global --add safe.directory /homelab/

# For some reason, when mounting vols inside the container, they're owned by root.
# This fixes it inside the container I suppose.....
find /homelab/ -type d -exec chown ${USER_NAME} {} +

chown ${USER_NAME} /homelab/requirements.*
chown -R ${USER_NAME} /homelab/roles/
chown -R ${USER_NAME} /home/${USER_NAME}/.doppler

# Using exec replaces the entrypoint.sh process as the new PID 1 in the container.
# The replacement of the container PID 1 process means your application process
# will now receive any signals sent by the container runtime such as SIGINT
# to trigger a graceful shutdown of your application.
# Run all commands through doppler
tail -f /dev/null
# exec gosu ${USER_NAME} "$@"
