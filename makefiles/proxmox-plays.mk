###########
# Proxmox #
###########

proxmox:
	@ansible-playbook -i inventory/hosts.ini playbook_proxmox.yml

proxmox-v:
	@ansible-playbook -vvv -i inventory/hosts.ini playbook_proxmox.yml

# Provision proxmox vm's.
proxmox-vms:
	@ansible-playbook -i inventory/hosts.ini --tags "provision_vms" -e "provision_vms=true" playbook_proxmox.yml

# Create Ubuntu VM Template in Proxmox.
proxmox-vm-template:
	@ansible-playbook -i inventory/hosts.ini --tags "create_vm_template" -e "create_vm_template=true" playbook_proxmox.yml

# Force (re)create/(re)download Ubuntu VM Template in Proxmox form public ubuntu cloud-init image. Essentially if you want to remake the iamge from scratch, make this target.
proxmox-force-vm-template:
	@ansible-playbook -i inventory/hosts.ini --tags "create_vm_template" -e "create_vm_template=true force_template_rebuild=true" playbook_proxmox.yml
