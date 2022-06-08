#!/usr/bin/env python3

import sys
import os

env_pass = os.environ.get('VAULT_PASS')

if env_pass is not None:
  password = env_pass
elif len(sys.argv) > 1:
  # in case there are spaces, no quotes or whatever the user does
  password = ''.join(sys.argv[1::])
else:
  sys.exit('No password defined in env or passed as arg.')

folderpath = f'{os.getcwd()}/'
filename = '.vault-password'
filepath = folderpath + filename

# If file exists and isn't empty, let's break out early
if os.path.exists(filepath) and not os.stat(filepath).st_size == 0:
    print("Password already exists, breaking.")
    sys.exit(0)

elif not os.path.isdir(folderpath):
    os.mkdir(folderpath)

with open(filepath, 'w+') as f:
    f.write(password)

with open(filepath) as f:
    written_pw = f.read()

if written_pw != password:
    print("Something went wrong and the password didn't get written correctly...")
    sys.exit(1)

print(f"Success!\nWrote password '{password}' to file '{filepath}'.")
