#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

if ! [ -s .vault-password ]; then
  ./bin/parse_pass.py
fi

/bin/bash
