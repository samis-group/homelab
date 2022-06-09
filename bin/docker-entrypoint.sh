#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

# Aliases
echo "alias ll='ls -alh'" >> ~/.bashrc

# Store password if it's not there already
if ! [ -s .vault-password ]; then
  sudo ./bin/parse_pass.py
fi

# Start SSH inside entrypoint for ansible tasks delegated to localhost (container)
sudo service ssh start > /dev/null

# Setup githook so we don't make changes and accidentally submit unencrypted vaults
sudo make githook > /dev/null

# Give shell
/bin/bash
