###########
# Proxmox #
###########
.PHONY: proxmox proxmox-run-tags proxmox-run-tags-v proxmox-vm-template proxmox-force-vm-template proxmox-provision-docker-vms proxmox-provision-k3s-vms

proxmox:	## 🖥️ Main Proxmox playbook
	@ansible-playbook -i inventory/hosts.ini playbook_proxmox.yml $(runargs)

proxmox-run-tags:	## 🖥️ Run only the tags passed in separated by comma (e.g. make run-tags provision_lxcs)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) -e "$(runargs)=true" playbook_proxmox.yml

proxmox-run-tags-v:	## 🖥️ VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags provision_lxcs)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) -e "$(runargs)=true" playbook_proxmox.yml -vvvv

proxmox-vm-template:	## 🖥️ Create Ubuntu VM Template in Proxmox.
	@ansible-playbook -i inventory/hosts.ini --tags "create_vm_template" -e "create_vm_template=true" playbook_proxmox.yml $(runargs)

proxmox-force-vm-template:	## 🖥️ Force (re)create/(re)download Ubuntu VM Template in Proxmox form public ubuntu cloud-init image. Essentially if you want to remake the iamge from scratch, make this target.
	@ansible-playbook -i inventory/hosts.ini --tags "create_vm_template" -e "create_vm_template=true force_template_rebuild=true" playbook_proxmox.yml $(runargs)

proxmox-provision-docker-vms:	## 🖥️🐳 Provision docker vm's
	@ansible-playbook -i inventory/hosts.ini playbook_proxmox.yml --limit docker $(runargs)

proxmox-provision-k3s-vms:	## 🖥️☸ Provision k3s vm's
	@ansible-playbook -i inventory/hosts.ini playbook_proxmox.yml --limit k3s $(runargs)
