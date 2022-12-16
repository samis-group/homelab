# Homelab

![ubuntu-22-04](https://img.shields.io/badge/OS-Ubuntu%2022.04-blue)
![badge-windows-11](https://img.shields.io/badge/OS-Windows%2011%2021H2-blue)
![badge-license](https://img.shields.io/badge/License-MIT-informational)

![Gitlab pipeline status](https://img.shields.io/gitlab/pipeline-status/sami-group/homelab?branch=main&style=for-the-badge)

![Ansible](https://avatars.githubusercontent.com/u/1507452?s=200&v=4)
![Hashicorp](https://avatars.githubusercontent.com/u/761456?s=200&v=4)
![Docker](https://avatars.githubusercontent.com/u/38573177?s=200&v=4)
![kubernetes](https://avatars.githubusercontent.com/u/13629408?s=200&v=4)

This repository contains all of my automations to install and configure everything in my homelab, from scratch. You are able to completely tear this down and rebuild it.

There is so much it can do, but some key things you can achieve, from just a debian box (cluster to come):

- Spin up and configure proxmox (not yet tested)
- Download and build an ubuntu template from the Ubuntu public cloud image
- Clones the template to a docker vm and deploys my entire docker stack, all setup and configured (There is even a make target to restore the data from backups)
- Setup a single node or cluster (with HA) k3s deployment (you can even spin this up on VM's on your PC - Tested Windows + WSL + Virtualbox setup). Check the [Molecule Readme](molecule/README.md) for more info. **Note:** Ensure that you have installed the vagrant plugins for WSL2. I do it In my playbook. [Just run this command manually to install them.](https://gitlab.com/sami-group/homelab/-/blob/main/tasks/wsl/virtualbox.yml#L21).
- Sets up reverse proxy (treafik) [k3s traefik is WIP]
- Cloudflare DNS
- This repo can even setup my windows/linux desktop PC's and bootstrap my WSL instance(s).
- *Heaps of other stuff...*

❗ **DNS is managed manually for the docker containers, but any VM's will have DNS created for them. There are no current plans for me to automate creating container records, i know there is a container that will do this for you but I haven't looked into it. Soz..**

❗ **My Host inventories are managed in a private submodule. I've provided examples for you based off them to use. Head over to #if-you-are-not-me heading below for steps on what you need to do to setup this repo to run the bits yourself.**

❗ **This Playbook is fully configurable. You can skip or reconfigure any task by [Overriding Defaults](#overriding-defaults).**

## Contents

- [TL;DR](#tldr)
- [Initial Setup Tasks](#initial-setup-tasks)
  - [Proxmox Host](#proxmox-host)
  - [Windows Host + WSL](#windows-host--wsl)
- [If You Are Not Me](#if-you-are-not-me)
  - [Deploying Your SSH key](#deploying-your-ssh-key)
- [Deploying Automation(s)](#deploying-automations)
  - [Docker Image](#docker-image)
  - [Common makes with examples](#common-makes-with-examples)
  - [Lesser Used Make Targets](#lesser-used-make-targets)
  - [Running a specific set of tagged tasks](#running-a-specific-set-of-tagged-tasks)
- [Troubleshooting](#troubleshooting)
- [Overriding Defaults](#overriding-defaults)
- [Things to note](#things-to-note)
  - [Recursively pull in git](#recursively-pull-in-git)
  - [Proxmox VM ID namespaces](#proxmox-vm-id-namespaces)
- [Tasks to perform after playbook is complete](#tasks-to-perform-after-playbook-is-complete)
- [Author](#author)
- [License](#license)
- [Resources and Shout Outs](#resources-and-shout-outs)

## TL;DR

❗ **Ensure you already have docker installed and working on your local PC**. This pulls an image, sets it up and drops you in shell to run any make target you want.

Run the following commands to bring this entire project up from nothing but proxmox (nothing but debian soon to come once I have new hardware to test it all as I need a spare bare metal host):

> Clone the repo

```bash
cd ~/git/personal/
git clone git@gitlab.com:sami-group/homelab.git
cd homelab
```

> Go through setting up password. This also drops you in a container shell already setup to go.

```bash
make run-docker-registry-dotfiles
```

> Build my current stack

```bash
make execute
```

> Setup k3s HA vm's

```bash
make k3s
```

> Setup docker vm

```bash
make docker
```

- Optionally, run this to not spin up a container and ephemeral workspace and setup localhost wsl instance

> Setup local env first

```shell
export VAULT_PASS='ansible_vault_password'
make setup
```

> Make wsl, because default instance of WSL doesn't start SSH, so configure it first.

```bash
make wsl
```

## Initial Setup Tasks

### Proxmox Host

**Automation is implemented Mostly... but since I can't test it, manual steps are below after you install proxmox on the bare metal host.**

Install required dependencies (if required - i.e. first time):

```bash
ssh proxmox
apt install python3-pip && pip3 install proxmoxer requests
```

### Windows Host + WSL

- Install Chocolatey

  ```powershell
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  ```

- Install Docker-Desktop

  ```powershell
  choco install docker-desktop
  ```

- install WSL

  ```powershell
  wsl.exe --install
  ```

- Open docker-desktop > settings > Resources > WSL Integration > Enable Ubuntu

- Reboot

- Install OpenSSH Server

  ```powershell
  $openSSHpackages = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Select-Object -ExpandProperty Name

  foreach ($package in $openSSHpackages) {
    Add-WindowsCapability -Online -Name $package
  }

  # Start the sshd service
  Start-Service sshd
  Set-Service -Name sshd -StartupType 'Automatic'

  # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
  if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
  }
  else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
  }
  ```

- In wsl, go through initial user setup and install the following packages

  ```bash
  sudo apt update
  sudp apt upgrade
  sudo apt install make git
  ```

- Setup git dir structure

  ```bash
  mkdir -p ~/git/personal
  cd ~/git/personal
  ```

- Clone this dir (removing/substituting `glpat`)

  ```bash
  git clone https://username:glpat-xxxxxxxxxx@gitlab.com/sami-group/homelab.git
  ```

- Run the following command substituting your ansible vault password as required (skip inputting the password argument if you don't use ansible-vault or you have already stored this password). This will [install ansible and collection/role requirements](https://docs.ansible.com/ansible/latest/installation_guide/index.html), upgrade pip and install ansible collections/roles requirements, store your password inside of the file located in `.vault-password` for use with `ansible-vault` and deploy a githook to ensure you don't accidentally commit your vaulted files:

  ```bash
  # Use single quotes only!
  export VAULT_PASS='ansible_vault_password'
  make setup
  ```

| :exclamation:  IMPORTANT!  |
|----------------------------|

There is a ***very small*** chance that your password will not have exported into the file correctly as `make` and `bash` don't handle special characters well, as much as I tried to make it. It will be fine if you have a normal password with no successive backslashes like '\\\\' for example. The script will warn you if it failed and will tell you to use [this python script I built instead](./bin/parse_pass.py):

```bash
./bin/parse_pass.py 'super_secret_password'
```

**Note:** your ssh password will be your microsoft account password, if that's how you created your local user account.

## If You Are Not Me

- Copy the [hosts.ini](inventory/hosts.ini.example) file and fill it in with your host IP address and local admin account credentials (overwrite mine):

  ```bash
  cp inventory/hosts.ini.example inventory/hosts.ini
  ```

- overwrite [my own vaulted variables](group_vars/all/vars) with your vaulted items.

- **copy the [host_vars_example](host_vars_example/) folder as well**.

  ```bash
  cp host_vars_example host_vars
  ```

### Deploying Your SSH key

You should use `ssh-keygen` and `ssh-copy-id` if you have no SSH keys. [Google can help here](https://www.google.com). I have my own.

## Deploying Automation(s)

### Docker Image

You can build this repo inside a docker container and deploy any playbook from there, so it doesn't mess with your environment. I love ephemeral workspaces!

```bash
git clone https://username:glpat-xxxxxxxxxx@gitlab.com/sami-group/homelab.git ~/git/personal/homelab
cd ~/git/personal/homelab
```

> Build and run the public registry image (this also mounts the cloned dir and local ssh folder)

```bash
make run-docker-registry
```

> OR to add your dotfiles in

```bash
make run-docker-registry-dotfiles
```

### Common makes with examples

- Most common actions can be performed by issuing the associated `make` command. Go to the [Makefile](Makefile) and associated [makefiles](makefiles/) to see what it can do.
  - Most of these make commands that run plays where you need verbose output (-vvv), simply pass the ' -v' argument to the make target and it will run it verbosely, e.g. `make k3s ' -v'`.
    - **yes with the leading space, because there's no way that I've been able to figure out, how to pass '-v' to make without it thinking it's for Make.. Probably use stdin? needs testing..**
- *Alternatively*, you can run these playbooks the long hand way:

  ```bash
  ansible-playbook --vault-password-file ~/.ansible/password playbook_docker.yml
  ```

> Configure Windows host

  ```bash
  make windows
  ```

> Configure WSL-Personal instance

  ```bash
  make wsl-personal
  ```

> Configure docker VM in Proxmox

  ```bash
  make docker
  ```

> Restore docker container data from the NFS mount on docker2 (once configured) to docker2 VM's appdata.
> WARNING - This will potentially overwrite the current data

  ```bash
  make docker-restore-containers docker2
  ```

  > Then bring the stack up with - You won't have this if you aren't me.
  
  ```bash
  dcup all
  ```

> configure specific LXC host group. Get this from the inventory with `make edit-inventory`
> Check playbook_lxc.yml

  ```bash
  make lxc-LXC_HOST_GROUP_FROM_INVENTORY
  ```

> Configure gitlab runner LXC

  ```bash
  make lxc-gitlab_runner
  ```

> Create new default WSL Instance

```bash
make windows-runtags download_wsl_instance
```

### Lesser Used Make Targets

:information_source: If you want to encrypt/decrypt your files, just issue these commands:

> Decrypt vault

```bash
make decrypt
```

> Encrypt vault

```bash
make encrypt
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

## Troubleshooting

**TBA**. It should go smoothly, it's IaC + automation for a reason, right? I've already gone through the troubleshooting, it should just work, considering it starts and ends with stuff built by the community (apart from my own wrapper scripts), it's just ansible mainly. I've tried every where I could to reduce the amount of shell/command modules used, for compatibility and future support, no guarantees though.

To ensure connectivity, run the following command (specify the inventory file with the `-i` flag, if you are not running in the same directory as it):

```bash
ansible --vault-password-file ~/.ansible/password docker -m ping
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

## Things to note

### Recursively pull in git

When doing a git pull, recurse into submodules as well to pull any submodule updates, otherwise you'll potentially push old code into prod.

```bash
git pull --recurse-submodules
```

### Proxmox VM ID namespaces

❗ This is mainly just for me, you can namespace yours however you want, or adjust mine depending on your needs.

- 1XX - Personal Desktops and VM's
  - 10X - *Reserved for future use* (legacy resides here)
  - 11X - Family Desktop VM's
  - 17X - Remote Dev environments for playing with
- 2XX - Production VM's and LXC's for homelab environment
  - 20X - Production k3s
  - 21X - Production Docker w/ docker-compose files
  - 22X - Production LXC's
- 3XX - Development VM's and LXC's for homelab environment
  - 30X - Development k3s
  - 31X - Development Docker w/ docker-compose files
  - 32X - Development LXC's
- 8XXX - VM Templates

## Tasks to perform after playbook is complete

- Setup [PlexKodiConnect](https://github.com/croneter/PlexKodiConnect/wiki/Installation#automatic-installation-highly-recommended)

## Author

This project was created by [Sami Shakir](https://www.linkedin.com/in/sami-shakir/). Feel free to use/fork it.

## License

This software is available under the following licenses:

- **[MIT](./LICENSE)**

## Resources and Shout Outs

Resources and shout out to all these amazing people and all other online resources, y'all the MVP.

There may be some missing, so thanks to the FOSS community in general.

- [techno-tim/k3s-ansible](https://github.com/techno-tim/k3s-ansible)
- [ironicbadger-infra](https://github.com/ironicbadger/infra)
- [FuzzyMistborn-infra](https://github.com/FuzzyMistborn/infra)
