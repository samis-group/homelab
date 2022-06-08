# Homelab

![ansible-docker-logo](docs/assets/logo.png)

![ubuntu-20-04]
![badge-windows-10]
![badge-windows-11]
![badge-license]

This repository contains all of my playbooks and configurations to install and configure everything in my homelab, from scratch.

In other words, from just a debian box (cluster to come):

- You can spin up and configure (not yet tested) proxmox
- Download and build an ubuntu template from the Ubuntu public cloud image
- Clones the template to a docker vm and deploys my entire docker stack all setup and configured (There is even a make target to restore the data from backups)
  - There's currently a kubernetes migration taking place - I've automated + built the vm's and HA k3s stack.
  - I've started migrating to helm charts. I have 2 up, but I need to figure out how to architect deployments + services + ip allocation from my docker-compose stack. It's all TBD right now.
- Sets up reverse proxy
- Cloudflare DNS
- Heaps of other stuff

You are able to completely tear this down and rebuild it (this does not install proxmox yet, as that has not been tested yet. In the future it will).

This repo can even setup my windows/linux desktop PC's.

> ❗ **This playbook was tested on Ubuntu 22.04 and 20.04. Other versions may work but have not been tested.**
> ❗ **DNS is managed manually for the docker containers, but any VM's will have DNS created for them. There are no current plans for me to automate creating container records, i know there is a container that will do this for you but I haven't looked into it. Soz..**

## Contents

- [Homelab](#homelab)
  - [Contents](#contents)
  - [TL;DR](#tldr)
  - [Setup](#setup)
    - [Setup repo inside a docker container](#setup-repo-inside-a-docker-container)
    - [Setup the ansible control node (where you will run the playbook from) if not using docker method above](#setup-the-ansible-control-node-where-you-will-run-the-playbook-from-if-not-using-docker-method-above)
    - [Setup Proxmox Host](#setup-proxmox-host)
    - [Deploy SSH key and test](#deploy-ssh-key-and-test)
    - [Troubleshooting Host Setup](#troubleshooting-host-setup)
  - [Running the Playbook](#running-the-playbook)
    - [Running a specific set of tagged tasks](#running-a-specific-set-of-tagged-tasks)
  - [Overriding Defaults](#overriding-defaults)
  - [Common makes with examples](#common-makes-with-examples)
  - [Things to note](#things-to-note)
  - [Tasks to perform after playbook is complete](#tasks-to-perform-after-playbook-is-complete)
  - [Author](#author)
  - [License](#license)
  - [Resources](#resources)

## TL;DR

❗ Ensure you already have docker installed and working locally. This pulls an image, sets it up and drops you in shell to run any make target you want.

If you aren't me, this TLDR probably won't help you much, as I've got my variables encrypted in this repo. You won't have access, so read the long notes to set it all up.

Run the following commands to bring this entire project up from nothing but proxmox (nothing but debian soon to come once I have new hardware to test it all as I need a spare bare metal host):

```bash
# Clone the repo
cd ~/git/personal/ && git clone git@gitlab.com:sami-group/homelab.git && cd homelab

# Go through setting up password. This also drops you in a container shell already setup to go.
make run-docker-registry-dotfiles

# Build and configure proxmox host
make proxmox

# Setup k3s HA vm's
make k3s
```

Optionally, run this to not spin up a container and ephemeral workspace and setup localhost wsl instance:

```shell
# Setup local env first
make setup
# Make wsl, because default instance of WSL doesn't start SSH, so configure it first.
make wsl
```

It's literally as easy as that.

## Setup

### Setup repo inside a docker container

:exclamation: **In Beta!**

Yeah, you can now build this repo inside a docker container and deploy it from there, so it doesn't mess with your environment. I love ephemeral workspaces:

```bash
cd wherever
# Clone the repo
git clone git@gitlab.com:sami-group/homelab.git && cd homelab

# Build and run the public registry image (this also mounts the cloned dir and local ssh folder)
make run-docker-registry
```

> **NOTE:** The Playbook is fully configurable. You can skip or reconfigure any task by [Overriding Defaults](#overriding-defaults).

- Most common actions can be performed by issuing the associated `make` command. Go to the [Makefile](Makefile) and associated [makefiles](makefiles/) to see what it can do.
  - Most of these make commands that run plays where you need verbose output (-vvv), simply pass the ` -v` argument to the make target and it will run it verbosely, e.g. `make k3s ' -v'`.
    - **yes with the leading space, because there's no way that I've been able to figure out, how to pass '-v' to make without it thinking it's for Make.. Probably use stdin? needs testing..**

### Setup the ansible control node (where you will run the playbook from) if not using docker method above

*Pre-note for me*: run the alias `ssa` first ;)

1. Clone this repo locally (change to https method and don't recurse submodules if you aren't me): `git clone --recurse-submodules git@gitlab.com:sami-group/homelab.git`. **NOTE**: My Host inventories are managed in a private submodule.

2. Run the following command substituting your ansible vault password as required (skip inputting the password argument if you don't use ansible-vault or you have already stored this password). This will [install ansible and collection/role requirements](https://docs.ansible.com/ansible/latest/installation_guide/index.html), upgrade pip and install requirements, store your password inside of the file located in `~/.ansible/password` for use with `ansible-vault` and deploy a githook to ensure you don't accidentally commit your vaulted files:

```bash
# Use single quotes only!
export VAULT_PASS='super_secret_password'
make setup
```

| :exclamation:  IMPORTANT!  |
|----------------------------|

There is a ***very small*** chance that your password will not have exported into the file correctly as `make` and `bash` don't handle special characters well, as much as I tried to make it. It will be fine if you have a normal password with no successive backslashes like '\\\\' for example. The script will warn you if it failed and will tell you to use [this python script I built instead](./bin/parse_pass.py):

```bash
./bin/parse_pass.py 'super_secret_password'
```

3. Copy the [hosts.ini](inventory/hosts.ini.example) file and fill it in with your host IP address and local admin account credentials (overwrite mine):

```bash
cp inventory/hosts.ini.example inventory/hosts.ini
```

4. overwrite [my own vaulted variables](group_vars/all/vars) with your vaulted items.

:information_source: **If you want to encrypt/decrypt your files, just issue these commands**:

```bash
make decrypt
# or
make encrypt
```

If you are **NOT** the owner of this repo, **copy the [host_vars_example](host_vars_example/) folder as well**, otherwise if you're me, skip this as it should have imported your submodule previously (I use a private submodule).

```bash
cp host_vars_example host_vars
```

### Setup Proxmox Host

**Automation is TBD Mostly... Manual steps below after you install proxmox on the bare metal host.**

*This should now be part of the automation, but since I can't test it (as i need a new server), leaving here*.

Install dependencies required on the **proxmox host** (if required - i.e. first time):

```bash
ssh proxmox
apt install python3-pip && pip3 install proxmoxer requests
```

### Deploy SSH key and test

**TBA** deploy key, you should use `ssh-keygen` and `ssh-copy-id` if you have no SSH keys. [Google can help here](https://www.google.com). I have my own.

Now let's test to ensure connectivity. Specify the inventory file with the `-i` flag, if you are not running in the same directory as it, otherwise it's just:

```bash
ansible --vault-password-file ~/.ansible/password docker -m ping
```

Ensure that your inventory file is correctly setup (**Hint**: You can run `make decrypt` to decrypt your vaulted files):

```bash
ansible-vault edit --vault-password-file ~/.ansible/password inventory
```

### Troubleshooting Host Setup

**TBA**. Sorry been lazy documenting this, it should go smoothly, it's IaC + automation for a reason, right? I've already gone through the troubleshooting, it should just work, considering it starts and ends with stuff built by the community (apart from my own wrapper scripts), it's just ansible mainly. I've tried every where I could to reduce the amount of shell/command modules used, for compatibility and future support, no guarantees though.

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

Have a read through the playbooks to see which task you want to perform, and if it exists (There are tasks I just always want running).

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

- [vars/config.yml](vars/config.yml)
- [group_vars/all/vars](group_vars/all/vars)

## Common makes with examples

> Restore docker container data from the NFS mount on docker2 (once configured) to docker2 VM's appdata.
> WARNING - This will potentially overwrite the current data

```bash
make docker-restore-containers docker2
# Then bring the stack up with - You won't have this if you aren't me.
dcup all
```

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
