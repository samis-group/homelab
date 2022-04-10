#!/usr/bin/env python3

import sys
import os

# in case there are spaces, no quotes or whatever they do
password = ''.join(sys.argv[1::])
folderpath = os.path.expanduser('~/.ansible/')
filename = 'password'
filepath = folderpath + filename

# If file exists and isn't empty, let's break out early
if os.path.exists(filepath) and not os.stat(filepath).st_size == 0:
    sys.exit("Password already exists, breaking.")

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
