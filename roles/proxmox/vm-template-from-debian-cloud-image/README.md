# Create Proxmox Template from Ubuntu Cloud Image

This role creates a brand new proxmox template by downloading the specified version name of the ubuntu cloud image (e.g. jammy, bionic, focal, etc.) [published by the Canonical team here](https://cloud-images.ubuntu.com/). it provisions the VM in proxmox using this cloud image as the disk. It then converts it to a template for use later in your automations when defining which template to use to create your VM.

You can use this role to create a brand new template from the daily build (because it will use this by default, that is why you specify the version name, and they rebuild daily.), Just run this and it will force recreate it:

```bash
make **tbd**
```

You can create a play that runs this role and force re-creates/re-downloads the template from the public image, delete the old one and re-deploys the new one. Useful for rebuilding your template on a schedule or when a new release comes out. Simply pass the variable `force_template_rebuild=true` to the role and it will forcibly recreate the template. So use this role in a pipeline and build/boostrap your image weekly/monthly. WHATEVER you wish mate!

## Requirements

Proxmox server, with `promoxer` Ansible lastest version, tested on ansible core 2.11.5 with Python 3.8 Ansible comunity.general collection version 3.7.0 Proxmox API user and recommended ssh key for root in proxmox server

This role also requires the community.general collection to be installed mainly for the proxmox module.

## Usage

**tbd** right now.

## Project status

Still maintained

## Support

I don't plan to offer direct support for this. It's only a hobby for me.

If you want it to do something in addition to what this role already does, for this to use as a template and add your stuff to it. Learn ansible, if you haven't done so already, it's really easy if an ape like me can do it, I believe in you!

## Authors and acknowledgment

- Me **(Patting back intensifies)**.
- [Also credit to ferni95 for their role that I took bits off.](https://github.com/Ferni95/Ansible-Proxmox-VMs)
