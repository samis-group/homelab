#######
# WSL #
#######

wsl:
	@ansible-playbook -i inventory/hosts.ini playbook_wsl.yml $(runargs)

wsl-v:
	@ansible-playbook -i inventory/hosts.ini -vvv playbook_wsl.yml $(runargs)
