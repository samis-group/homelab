#######
# WSL #
#######

wsl:	## 🐧 Make WSL instance (Assumes you're running from it, so go setup and clone this repo there)
	@ansible-playbook -i inventory/hosts.ini playbook_wsl.yml $(runargs)
