###########
# Proxmox #
###########
.PHONY: proxmox proxmox-run-tags proxmox-run-tags-v proxmox-vm-template proxmox-force-vm-template proxmox-provision-%

proxmox:	## 🖥️ Main Proxmox playbook
	@ansible-playbook -i inventory/hosts.ini playbook_proxmox.yml $(runargs)

proxmox-run-tags:	## 🖥️ Run only the tags passed in separated by comma (e.g. make run-tags provision_lxcs)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) -e "$(runargs)=true" playbook_proxmox.yml

proxmox-run-tags-v:	## 🖥️ VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags provision_lxcs)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) -e "$(runargs)=true" playbook_proxmox.yml -vvvv

proxmox-ubuntu-vm-template:	## 🖥️ Create Ubuntu VM Template in Proxmox.
	@ansible-playbook -i inventory/hosts.ini --tags "create_ubuntu_vm_template" -e "create_ubuntu_vm_template=true" playbook_proxmox.yml $(runargs)

proxmox-force-ubuntu-vm-template:	## 🖥️ Force (re)create/(re)download Ubuntu VM Template in Proxmox from public ubuntu cloud-init image. Essentially if you want to remake the image from scratch, make this target.
	@ansible-playbook -i inventory/hosts.ini --tags "create_ubuntu_vm_template" -e "create_ubuntu_vm_template=true force_template_rebuild=true" playbook_proxmox.yml $(runargs)

proxmox-debian-vm-template:	## 🖥️ Create Debian VM Template in Proxmox.
	@ansible-playbook -i inventory/hosts.ini --tags "create_debian_vm_template" -e "create_debian_vm_template=true" playbook_proxmox.yml $(runargs)

proxmox-force-debian-vm-template:	## 🖥️ Force (re)create/(re)download Debian VM Template in Proxmox from public debian cloud-init image. Essentially if you want to remake the image from scratch, make this target.
	@ansible-playbook -i inventory/hosts.ini --tags "create_debian_vm_template" -e "create_debian_vm_template=true force_template_rebuild=true" playbook_proxmox.yml $(runargs)

proxmox-provision-%:	## 🖥️ Provision based on tags passed in. Check tags on the plays in `playbook_proxmox.yml` for more info. e.g. `make proxmox-provision-blah`
	@ansible-playbook -i inventory/hosts.ini -e "provision_vms=true" --tags $@ playbook_proxmox.yml $(runargs)

proxmox-provision-lxc:	## 🖥️ Provision LXC's.
	@ansible-playbook -i inventory/hosts.ini playbook_proxmox.yml --tags proxmox-provision-lxc $(runargs)
