#!/usr/bin/env python3

import sys
import os
from getpass import getpass

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Perform some checks
folderpath = f'{os.getcwd()}/provision/ansible/'
filename = '.vault-password'
filepath = folderpath + filename

# If file exists and isn't empty, let's break out early, otherwise ensure dir exists
if os.path.exists(filepath) and not os.stat(filepath).st_size == 0:
    print(f"{bcolors.OKBLUE}Password already exists, breaking.{bcolors.ENDC}")
    sys.exit(0)
elif not os.path.isdir(folderpath):
    os.mkdir(folderpath)

# Get password from env, args, or stdin
env_pass = os.environ.get('VAULT_PASS')
if env_pass is not None:
  password = env_pass
elif len(sys.argv) > 1:
  # in case there are spaces, no quotes or whatever the user does
  password = ''.join(sys.argv[1::])
else:
  print(f"{bcolors.WARNING}No Ansible Vault password defined in env or passed as arg. Please type it below...{bcolors.ENDC}")
  password = getpass()

# Write the password
with open(filepath, 'w+') as f:
    f.write(password)

# Check to ensure password is as we expect
with open(filepath) as f:
    written_pw = f.read()

if written_pw != password:
    print(f"{bcolors.FAIL}Something went wrong and the password didn't get written correctly. This requires investigation...{bcolors.ENDC}")
    sys.exit(1)

print(f"{bcolors.OKGREEN}Success!\nWrote password to file '{filepath}'.{bcolors.ENDC}")
