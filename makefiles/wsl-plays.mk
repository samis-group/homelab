#######
# WSL #
#######

wsl-versent:	## 🐧 Make Base + Versent WSL instance (Assumes you're running from it, so go setup and clone this repo there)
	@ansible-playbook -i inventory/hosts.ini playbook_wsl.yml playbook_wsl_versent.yml $(runargs)

wsl-personal:		## 🐧 Make Base + Personal WSL instance (Assumes you're running from it, so go setup and clone this repo there)
	@ansible-playbook -i inventory/hosts.ini playbook_wsl.yml playbook_wsl_personal.yml $(runargs)
