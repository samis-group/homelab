# Proxmox

## Setup the Ansible Control Node (where you will run the playbook from)

1. Clone this repo locally (change to https method if you aren't me): `git clone git@gitlab.com:sami-group/proxmox.git`

2. Run the following command substituting your ansible vault password as required (skip inputting the password argument if you don't use ansible-vault or you have already stored this password in `~/.ansible/password` as per my other playbooks). This will [install ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html), upgrade pip and store your password inside of the file located in `~/.ansible/password` for use with `ansible-vault`:

```bash
# Use single quotes only!
export VAULT_PASS='super_secret_password'
make setup
```

| :exclamation:  IMPORTANT!  |
|----------------------------|

There is a ***very small*** chance that your password will not have exported into the file correctly as `make` and `bash` don't handle special characters well, as much as I tried to make it. It will be fine if you have a normal password with no successive backslashes like '\\\\' for example. The script will warn you if it failed and will tell you to use [this python script instead](./bin/parse_pass.py):

```bash
./bin/parse_pass.py 'super_secret_password'
```

:information_source: **If you want to encrypt/decrypt your files, just issue these commands**:

```bash
make decrypt
# or
make encrypt
```
