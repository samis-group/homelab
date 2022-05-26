# Homelab

![Logo](files/logo.png)

![ubuntu-20-04]
![badge-windows-10]
![badge-windows-11]
![badge-license]

This repository contains all of my playbooks and configurations to install and configure everything in my homelab, from scratch (i.e. from just a few debian boxes, you can spin up an entire proxmox cluster, with docker/kubernetes vm's, all setup and configured, reverse proxy, DNS, the whole lot.. depending on the tech I'm using).

DNS is managed manually in cloudflare and there are no current plans for me to automate creating these records.. sorry. They're all essentially just CNAME's pointing to my reverse proxy (traefik for now).

It creates a ubuntu template from the public cloud image, creates my VM's on proxmox and configures all containers. You are able to completely tear this down and rebuild it (this does not install proxmox yet, in the future it will).

This repo can even setup my windows/linux desktop PC's.

> ❗ **This playbook was tested on Ubuntu 20.04. Other versions may work but have not been tested.**

## Contents

- [Homelab](#homelab)
  - [Contents](#contents)
  - [Playbook capabilities](#playbook-capabilities)
  - [Setup the Ansible Control Node (where you will run the playbook from)](#setup-the-ansible-control-node-where-you-will-run-the-playbook-from)
  - [Setup Proxmox Host](#setup-proxmox-host)
    - [Deploy SSH key and test](#deploy-ssh-key-and-test)
    - [Troubleshooting Host Setup](#troubleshooting-host-setup)
  - [Running the Playbook](#running-the-playbook)
    - [Running a specific set of tagged tasks](#running-a-specific-set-of-tagged-tasks)
  - [Overriding Defaults](#overriding-defaults)
  - [Things to note](#things-to-note)
  - [Tasks to perform after playbook is complete](#tasks-to-perform-after-playbook-is-complete)
  - [Author](#author)
  - [License](#license)
  - [Resources](#resources)

## Playbook capabilities

> **NOTE:** The Playbook is fully configurable. You can skip or reconfigure any task by [Overriding Defaults](#overriding-defaults).

- Most common actions can be performed by issuing the associated `make` command. Go to the [Makefile](Makefile) to see what it can do.
  - Most of these make commands that run plays where you need verbose output (-vvv), simply append `-v` to the make target and it will run it verbosely, e.g. `make update-compose-v`

## Setup the Ansible Control Node (where you will run the playbook from)

1. Clone this repo locally (change to https method and don't recurse submodules if you aren't me): `git clone --recurse-submodules git@gitlab.com:sami-group/homelab.git`. **NOTE**: My Host inventories are managed in a private submodule.

2. Run the following command substituting your ansible vault password as required (skip inputting the password argument if you don't use ansible-vault or you have already stored this password). This will [install ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html), upgrade pip and store your password inside of the file located in `~/.ansible/password` for use with `ansible-vault`:

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

3. Copy the [hosts.ini](inventory/hosts.ini.example) file and fill it in with your host IP address and local admin account credentials (overwrite mine):

```bash
cp inventory/hosts.ini.example inventory/hosts.ini
```

4. Do the same with the [vault](vars/vault.yml) (overwrite mine).

```bash
cp vars/vault.yml.example vars/vault.yml
```

:information_source: **If you want to encrypt/decrypt your files, just issue these commands**:

```bash
make decrypt
# or
make encrypt
```

## Setup Proxmox Host

**Automation is TBD Mostly... Manual steps below after you install proxmox on the bare metal host.**

Install dependencies required on the **proxmox host** (if required - i.e. first time):

```bash
ssh proxmox
apt install python3-pip && pip3 install proxmoxer requests
```

### Deploy SSH key and test

**TBA** deploy key

Now let's test to ensure connectivity (specify the inventory file if not running in the same dir as it with the `-i` flag):

```bash
ansible --vault-password-file ~/.ansible/password docker -m ping
```

Ensure that your inventory file is correctly setup (**Hint**: You can run `make decrypt` to decrypt your vaulted files:

```bash
ansible-vault edit --vault-password-file ~/.ansible/password inventory
```

### Troubleshooting Host Setup

**TBA**.

## Running the Playbook

If you have setup your vault password and ran the `make setup` task successfully, just run the following to execute the playbook in it's entirety:

```bash
make
# or
make execute
```

*Alternatively*, the long hand way:

```bash
ansible-playbook --vault-password-file ~/.ansible/password main.yml
```

### Running a specific set of tagged tasks

You can also filter which part of the provisioning process to run by specifying a set of tags like so:

```bash
make run-tags logrotate,install_docker
```

*Alternatively*, the long hand way:

```bash
ansible-playbook --vault-password-file ~/.ansible/password main.yml --tags "logrotate,install_docker"
```

❗ The tags available can be listed by running this command:

```bash
make list-tags
```

## Overriding Defaults

You can override any of the defaults configured in these playbooks by adding your entries to the `vars/config.yml` file. For example, you can tell it to configure the hostname, and pass in the hostname value to configure it to with something like:

```yaml
configure_hostname: true
custom_hostname: myhostname
```

For a full list of variables, run this:

```bash
make list-vars
```

Check the following files for these configurable items:

- [group_vars/all](group_vars/all)
- [vars/default_config.yml](vars/default_config.yml)
- [vars/config.yml](vars/config.yml)
- [vars/vault.yml](vars/vault.yml)

## Things to note

When doing a git pull, recurse into submodules as well to pull any submodule updates, otherwise you'll potentially push old code into prod.

```bash
git pull --recurse-submodules
```

## Tasks to perform after playbook is complete

1. Setup [PlexKodiConnect](https://github.com/croneter/PlexKodiConnect/wiki/Installation#automatic-installation-highly-recommended)

## Author

This project was created by [Sami Shakir](https://www.linkedin.com/in/sami-shakir/). Feel free to use/fork it.

## License

This software is available under the following licenses:

- **[MIT](./LICENSE)**

[ubuntu-20-04]: https://img.shields.io/badge/OS-Ubuntu%2020.04-blue
[badge-windows-10]: https://img.shields.io/badge/OS-Windows%2010%2020H2-blue
[badge-windows-11]: https://img.shields.io/badge/OS-Windows%2011%2021H2-blue
[badge-license]: https://img.shields.io/badge/License-MIT-informational

## Resources

Resources (or just cool stuff i plan to implement) that I used to build stuff will be put here, there may be some missing, so thanks to the FOSS community in general.

[ironicbadger-infra](https://github.com/ironicbadger/infra)

[FuzzyMistborn-infra](https://github.com/FuzzyMistborn/infra)

[techno-tim/k3s-ansible](https://github.com/techno-tim/k3s-ansible)
