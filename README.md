# Homelab

![ubuntu-22-04](https://img.shields.io/badge/OS-Ubuntu%2022.04-blue)
![badge-windows-11](https://img.shields.io/badge/OS-Windows%2011%2021H2-blue)
![badge-license](https://img.shields.io/badge/License-MIT-informational)

![Gitlab pipeline status](https://img.shields.io/gitlab/pipeline-status/sami-group/homelab?branch=main&style=for-the-badge)

![Ansible](https://avatars.githubusercontent.com/u/1507452?s=200&v=4)
![Hashicorp](https://avatars.githubusercontent.com/u/761456?s=200&v=4)
![Docker](https://avatars.githubusercontent.com/u/38573177?s=200&v=4)
![kubernetes](https://avatars.githubusercontent.com/u/13629408?s=200&v=4)

This repository contains all of my automations to install and configure everything in my homelab, from scratch. You are able to completely tear this down and rebuild it from Proxmox on bare metal.

❗ **You need to install Proxmox on the bare metal manually. I use [ventoy](https://www.ventoy.net/en/index.html) as a solution to boot any ISO on any computer from a usb stick and run through steps manually. For me this works and I don't have to do it often.**

❗ **This project makes heavy use of `go-task` in order to run all of the automations in sequence. [Please download it from here](https://taskfile.dev/installation/) as you will need to use it to run the workstation.**

❗ **DNS is managed manually for the docker containers, but any VM's will have DNS created for them. There are no current plans for me to automate creating container records, i know there is a container that will do this for you but I haven't looked into it. Soz..**

❗ **You can skip or reconfigure any variable in any task by [Overriding Defaults](#overriding-defaults).**

❗ **Ensure you already have docker installed and working on your local PC**. This pulls an image, sets it up and drops you in shell to run any task you want.

## TL;DR

### Proxmox host setup

#### SSH Key Copy

Copy your public ssh key over to your proxmox hosts by logging in and putting the key inside `/root/.ssh/authorized_keys` file.

#### Resize Main Partition

Resize your `local` volume [like so in this video](https://youtu.be/_u8qTN3cCnQ?t=887) to reclaim full space of your disk for use with vm's etc. Essentially the steps are:

1. Remove local-lvm disk.
2. lvremove /dev/pve/data
   1. y
3. lvresize -l +100%FREE /dev/pve/root
4. resize2fs /dev/mapper/pve-root

Also ensure that `local` disk can store disk images by going into Datacenter > Storage > Edit local > Content > Ensure Disk Image is one of the selected items.

### Workstation Docker Image

You can build this repo and run any of its tasks inside a pre-built docker image with the tools to do all the work, so it doesn't mess with your environment. Ephemeral workspaces be the future?!

```bash
git clone https://username:glpat-xxxxxxxxxx@gitlab.com/sami-group/homelab.git ~/git/personal/homelab
cd ~/git/personal/homelab
```

> Build and run the public registry image (this also mounts the cloned dir, local ssh folder, and a bunch of others). start the container and drop you in a shell already setup to go.

```bash
task ws:s
```

### Common tasks with examples

- Most common actions can be performed by issuing the associated `task` command. Go to the [Taskfile](Taskfile.yml) and associated [taskfiles](.taskfiles/) to see what it can do.
  - Most of these task commands that run plays where you need verbose output (-vvv), simply pass the ' -v' argument (including leading space) to the task and it will run it verbosely, e.g. `task k3s ' -v'`.

> Build my current stack

```bash
task all
```

> Setup Proxmox Hosts for workloads

```bash
task proxmox:main
```

> Setup k3s HA vm's

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

> configure dev machine.

```bash
task lxc:dev
```

> If you make changes to the [generated inventory](provision/ansible/inventory/generated.yml), you can save and push it back to doppler

```bash
task doppler:push-inventory
```

## Overriding Defaults

You can override any of the defaults configured in these playbooks by adding your entries to the `vars/config.yml` file. For example, you can tell it to configure the hostname, and pass in the hostname value to configure it to with something like:

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
