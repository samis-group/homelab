#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

# Set the user and group IDs at container runtime based on host system
# This will allow us to mount content from our FS without perms issues inside the container
echo "usermod -u ${USER_ID} ${USER_NAME}"
usermod -u ${USER_ID} ${USER_NAME}
# echo "groupmod -u ${GROUP_ID} ${GROUP_NAME}"
# groupmod -g ${GROUP_ID} ${GROUP_NAME}

# Aliases
gosu ${USER_NAME} echo "alias ll='ls -alh'" >> /home/ubuntu/.bashrc

# Start SSH inside entrypoint for ansible tasks delegated to localhost (container)
echo "Starting sshd..."
service ssh start > /dev/null

echo "Setting git safe dir..."
git config --global --add safe.directory /

# Using exec replaces the entrypoint.sh process as the new PID 1 in the container.
# The replacement of the container PID 1 process means your application process
# will now receive any signals sent by the container runtime such as SIGINT
# to trigger a graceful shutdown of your application.
# Run all commands through doppler
tail -f /dev/null
# exec gosu ${USER_NAME} "$@"
