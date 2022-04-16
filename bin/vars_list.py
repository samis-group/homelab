#!/usr/bin/env python3

import os
import sys
import yaml
import configparser

def prRed(skk): print("\033[91m{}\033[00m" .format(skk))

files = sys.argv[1:]
# Python doesn't recognize 'tilde' as the home user. It isn't shell so it can't expand this, it reads the literal character, so let's set it.
home = os.path.expanduser("~")
ansible_password_file = f"{home}/.ansible/password"
if not os.path.isfile(ansible_password_file):
  sys.exit(f"Unable to access password file, please ensure it exists and you've setup your environment with `make setup`.")
yaml_file_prefixes = ('yaml', 'yml')
print()

for file in files:
  if os.path.isfile(file):
    with open(file) as fh:
      prRed(f"Processing file '{file}':")
      data = fh.read()
    # Let's decrypt the file into a variable if it's encrypted. We don't want to leave it unencrypted on the filesystem
    if "$ANSIBLE_VAULT;" in data:
      data = os.popen(f"ansible-vault view --vault-password-file {ansible_password_file} {file}").read()
    # Logic for if it's yaml or ini
    if file.endswith(yaml_file_prefixes):
      data = yaml.load(data, Loader=yaml.FullLoader)
      print(yaml.dump(data, indent=2, default_flow_style=False))
    else:
      config = configparser.ConfigParser(allow_no_value=True)
      try:
        config.read_string(data)
        for section in config.sections():
          print(f'[{section}]')
          for key in config[section]:
            print(f"{key}: {config[section][key]}")
          print()
      except configparser.MissingSectionHeaderError:
        print("Missing section, please review...\n")
  else:
    pass
