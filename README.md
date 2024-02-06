# Homelab

![ubuntu-22-04](https://img.shields.io/badge/OS-Ubuntu%2022.04-blue)
![badge-windows-11](https://img.shields.io/badge/OS-Windows%2011%2021H2-blue)
![badge-license](https://img.shields.io/badge/License-MIT-informational)

[![Docker Image - Workstation](https://github.com/samis-group/homelab/actions/workflows/docker-image-workstation.yaml/badge.svg?branch=main)](https://github.com/samis-group/homelab/actions/workflows/docker-image-workstation.yaml)
[![Docker Image - Actions Runner Base](https://github.com/samis-group/homelab/actions/workflows/docker-image-actions-runner-base.yaml/badge.svg)](https://github.com/samis-group/homelab/actions/workflows/docker-image-actions-runner-base.yaml)

![Ansible](https://avatars.githubusercontent.com/u/1507452?s=200&v=4)
![Hashicorp](https://avatars.githubusercontent.com/u/761456?s=200&v=4)
![Docker](https://avatars.githubusercontent.com/u/38573177?s=200&v=4)
![kubernetes](https://avatars.githubusercontent.com/u/13629408?s=200&v=4)

This repository contains all of my automations to install and configure everything in my homelab, from scratch. You are able to completely tear this down and rebuild it from Proxmox on bare metal.

![Homelab Diagram](docs/assets/Homelab.png)

❗ **Ensure you already have docker installed and working on your local PC**. This pulls an image, sets it up and drops you in shell to run any task you want.

❗ **This project makes heavy use of `go-task` in order to run all of the automations in sequence. [Please download it from here](https://taskfile.dev/installation/) as you will need to use it to run the docker image workstation where the automations are applied from.**

❗ **You can skip or reconfigure any variable in any task by [Overriding Defaults](#overriding-defaults).**

❗ **I've provided an example of all my [doppler secrets here](docs/doppler_secrets_example.md).**

## Workstation Docker Image

You can build this repo and run any of its tasks inside a pre-built docker image with all the tools to do the work, so it doesn't mess with your local environment. The steps are as follows:

```bash
mkdir -p ~/git/personal/
git clone --recurse-submodules https://github.com/samis-group/homelab.git ~/git/personal/homelab
cd ~/git/personal/homelab
```

Build and run the public registry image, start the container and drop you in a shell already setup to go.

This also mounts the following directories from your host to the container:

- Repository directory - `${PWD}`
- Local users ssh folder - `${HOME}/.ssh`
- Doppler config located at `${HOME}/.doppler`
- Users kubeconfig file located at `${HOME}/.kube`
- Perhaps a few others depending on the task that is being run. Comment out the ones you don't need in ['DOCKER_RUN_CMD' here](https://gitlab.com/sami-group/homelab/-/blob/main/.taskfiles/Workstation.yml#L9).

```bash
task ws:s
```

## TL;DR

### Proxmox host setup

❗ **You need to install Proxmox on the bare metal manually. I use [ventoy](https://www.ventoy.net/en/index.html) as a solution to boot any ISO on any computer from a usb stick and run through steps manually. For me this works and I don't have to do it often.**

#### Copy SSH Key to proxmox host

Let's define a few variables in your environment. I deploy my public github keys to all/most of my machines as I have the private key in my password manager and can generally always put it where it's needed. **Security concerns be damned**, this isn't a production environment for a hospital...

```bash
GITHUB_USER="your-github-username"
PROXMOX_HOST="10.10.0.11"
```

Prereq: Ensure you can ssh as root to your machine

```bash
ssh root@$PROXMOX_HOST
```

If you can not:

```bash
ssh user@$PROXMOX_HOST
su
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
exit
exit
```

Finally, copy your public ssh key(s) from github over to your proxmox hosts:

```bash
PUBLIC_KEYS=$(curl -s "https://github.com/$GITHUB_USER.keys")
ssh root@$PROXMOX_HOST "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys"
while IFS= read -r line; do
    echo "$line" | ssh root@$PROXMOX_HOST "cat >> ~/.ssh/authorized_keys"
done <<< "$PUBLIC_KEYS"
```

#### Resize Main ('local') Partition

Resize your `local` volume [like so in this video](https://youtu.be/_u8qTN3cCnQ?t=887) to reclaim full space of your disk for use with vm's etc. Essentially the steps are:

1. Remove local-lvm disk in gui.
2. in cli: `lvremove /dev/pve/data`
   1. `y`
3. `lvresize -l +100%FREE /dev/pve/root`
4. `resize2fs /dev/mapper/pve-root`

Also ensure that `local` disk can store disk images by going into Datacenter > Storage > Edit local > Content > Ensure Disk Image is one of the selected items.

### Common tasks with examples

- Most common actions can be performed by issuing the associated `task` command. Go to the [Taskfile](Taskfile.yml) and associated [taskfiles](.taskfiles/) to see what it can do.
  - Most of these task commands that run plays where you need verbose output (-vvv), simply pass the ' -v' argument (including leading space) to the task and it will run it verbosely, e.g. `task k3s ' -v'`.

> Build my entire current stack

```bash
task all
```

> Setup Proxmox Hosts for workloads

```bash
task proxmox:main
```

> Setup k3s vm(s)

```bash
task k3s:main
```

> Setup docker vm

```bash
task docker:main
```

> Configure wsl-personal instance

```bash
task wsl:personal
```

> Configure Windows host

```bash
task windows:main
```

Get a list of LXC's from the [generated inventory](provision/ansible/inventory/generated.yml) or [lxc taskfile](.taskfiles/Lxc.yml).

> provision and configure all current LXC's.

```bash
task lxc:main
```

> configure gitlab runner LXC.

```bash
task lxc:gitlab-runner
```

> configure dev LXC.

```bash
task lxc:dev
```

> If you make changes to the [generated inventory](provision/ansible/inventory/generated.yml), you can save and push it back to doppler.

```bash
task doppler:push-inventory
```

## Overriding Defaults

You can override any of the defaults configured in these playbooks by adding your entries to [this vars file](provision/ansible/vars.yml). For example, you can tell it to configure the hostname, and pass in the hostname value to configure it to with something like:

```yaml
configure_hostname: true
custom_hostname: myhostname
```

Check the following files for these configurable items:

- [provision/ansible/inventory - contains most of all of the variables](provision/ansible/inventory)
- [provision/ansible/vars.yml - Contains overrides](provision/ansible/vars.yml)
- [provision/ansible/inventory/group_vars/all/vars.yml - Main file containing vars for everything to inherit](provision/ansible/inventory/group_vars/all/vars.yml)

## Proxmox VM ID namespaces

❗ This is mainly just for me, you can namespace yours however you want, or adjust mine depending on your needs.

- 1XX - Personal Desktops and VM's
  - 10X - *Legacy Stuff*
  - 11X - Desktop VM's
- 2XX - Production VM's and LXC's for homelab environment
  - 20X - Production k3s
  - 21X - Production Docker w/ docker-compose files
  - 22X - Production LXC's
- 3XX - Development VM's and LXC's for homelab environment
- 8XXX - VM Templates

## Creating a new VM group from a template in Proxmox

- Pull the latest ansible inventory file from doppler with `task dp:pulla`
- Make changes under `all -> children -> linux -> children` and add an entry for your VM to this list
  - You can follow my pattern of creating a group, then a list of hosts (to allow scalability) and then define the VM name and host:
    - `vm_group_name` -> `hosts` -> `vm1` -> `ansible_host: vm1.domain.com`
- Push the changes back to doppler with `task dp:pusha`
- Create a provisioning step for your vm in the file `homelab/provision/ansible/playbooks/proxmox_vms.yml` [based off this docker vm](https://github.com/samis-group/homelab/blob/29623d547eea7c3659e0fc7c17e65765ed5d32de/provision/ansible/playbooks/proxmox_vms.yml#L2-L10).
- Create a copy of the [host vars file](https://github.com/samis-group/homelab/blob/30cb20e52bdab7dec0db1ec00d407d48ad04ca57/provision/ansible/inventory/host_vars/docker1.yml) for your vm in the folder, using docker1 vm as an example -> `provision/ansible/inventory/host_vars/docker1.yml`.
  - Configure a few things in here. You *must* change the following, set others per your requirements:
    - `ID` of the VM - must be different per VM
    - `vm_ip_address` - must be different per VM
- Create an entry for your vm in the file `homelab/.taskfiles/Proxmox.yml` [just like this docker vm](https://github.com/samis-group/homelab/blob/29623d547eea7c3659e0fc7c17e65765ed5d32de/.taskfiles/Proxmox.yml#L67-L74).
- Run your task: `task proxmox:provision-vm_group_name`

## Troubleshooting

To ensure connectivity, run the following command (specify the inventory file with the `-i` flag, if you are not running in the same directory as it):

```bash
ansible -i provision/ansible/inventory docker -m ping
```

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
