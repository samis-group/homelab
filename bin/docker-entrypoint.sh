#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

# Store password if it's not there already
if ! [ -s .vault-password ]; then
  ./bin/parse_pass.py
fi

# Start SSH inside entrypoint for ansible tasks delegated to localhost (container)
sudo service ssh start > /dev/null

# Setup githook so that we don't make changes and accidentally submit unencrypted vaults
make githook > /dev/null

# Give shell
/bin/bash
