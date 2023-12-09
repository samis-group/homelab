#!/bin/bash -e

# Set the user and group IDs at container runtime based on host system
# This will allow us to mount content from our FS without perms issues inside the container
echo "usermod -u ${USER_ID} ${USER_NAME}"
usermod -u ${USER_ID} ${USER_NAME}
# echo "groupmod -u ${GROUP_ID} ${USER_NAME}"
# groupmod -g ${GROUP_ID} ${USER_NAME}

# Start SSH inside entrypoint for ansible tasks delegated to localhost (container)
echo "Starting sshd..."
service ssh start > /dev/null

echo "Setting git safe dir..."
gosu ${USER_NAME} git config --global --add safe.directory ${HOMELAB_DIR}/

# For some reason, when mounting vols inside the container, they're owned by root.
# This fixes it inside the container I suppose.....
find ${HOMELAB_DIR}/ -type d -exec chown ${USER_NAME} {} +

chown ${USER_NAME} ${HOMELAB_DIR}/requirements.*
chown -R ${USER_NAME} ${HOMELAB_DIR}/roles/
chown -R ${USER_NAME} /home/${USER_NAME}/
# chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.doppler
# chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.kube
# chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.terraform.d

# If k3s lxc is deployed, get the config but leave the pipeline as a success if it fails
gosu ${USER_NAME} task --dir /workspace/homelab/ k3s:scp-kubeconfig > /dev/null || true

# Using exec replaces the entrypoint.sh process as the new PID 1 in the container.
# The replacement of the container PID 1 process means your application process
# will now receive any signals sent by the container runtime such as SIGINT
# to trigger a graceful shutdown of your application.
# Run all commands through doppler
tail -f /dev/null
# exec gosu ${USER_NAME} "$@"
