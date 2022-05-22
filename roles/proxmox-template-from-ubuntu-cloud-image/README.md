# Create Proxmox Template from Ubuntu Cloud Image

[Credit to ferni95 for their role that I based this off.](https://github.com/Ferni95/Ansible-Proxmox-VMs)

This role creates a brand new proxmox template by downloading the specified version name of the ubuntu cloud image (e.g. jammy, bionic, focal, etc.) [published by the Canonical team here](https://cloud-images.ubuntu.com/). it provisions the VM in proxmox using this cloud image as the disk. It then converts it to a template for use later in your automations when defining which template to use to create your VM.

You can use this role to create a brand new template from the daily build (because it will use this by default, that is why you specify the version name, and they rebuild daily.), Just run this and it will force recreate it:

## Notes

You can create a play that runs this role and force re-creates/re-downloads the template from the public image, delete the old one and re-deploys the new one. Useful for rebuilding your template on a schedule or when a new release comes out. Simply pass the variable `force_template_rebuild=true` to the role and it will forcibly recreate the template.
