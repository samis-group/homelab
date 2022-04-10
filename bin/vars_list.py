#!/usr/bin/env python3

import sys
import yaml
import configparser

def prRed(skk): print("\033[91m{}\033[00m" .format(skk))

files = sys.argv[1:]

yaml_file_prefixes = ('yaml', 'yml')
print()
for file in files:
  with open(file) as fh:
    prRed(f"Processing file '{file}':")
    if file.endswith(yaml_file_prefixes):
      data = yaml.load(fh, Loader=yaml.FullLoader)
      if "$ANSIBLE_VAULT;" in data:
        print("File is encrypted, please decrypt with `make decrypt` and try again. Skipping...\n")
      else:
        print(yaml.dump(data, indent=2, default_flow_style=False))
    else:
      config = configparser.ConfigParser(allow_no_value=True)
      try:
        config.read(file)
        for section in config.sections():
          print(f'[{section}]')
          for key in config[section]:
            print(f"{key}: {config[section][key]}")
          print()
      except configparser.MissingSectionHeaderError:
        print("File is encrypted, please decrypt with `make decrypt` and try again. Skipping...\n")
