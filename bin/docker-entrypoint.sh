#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

# Aliases
echo "alias ll='ls -alh'" >> ~/.bashrc

# Store password if it's not there already
if ! [ -s .vault-password ]; then
  sudo parse_pass.py
fi

# Start SSH inside entrypoint for ansible tasks delegated to localhost (container)
echo "Starting sshd..."
sudo service ssh start > /dev/null

echo "Setting git safe dir..."
git config --global --add safe.directory /

# Keep container up
tail -f /dev/null
