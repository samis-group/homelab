#######
# WSL #
#######

wsl-work:	## 🐧 Make Base + Work WSL instance (Assumes you're running from it, so go setup and clone this repo there)
	@ansible-playbook -i inventory/hosts.ini playbook_wsl.yml playbook_wsl_work.yml $(runargs)

wsl-personal:		## 🐧 Make Base + Personal WSL instance (Assumes you're running from it, so go setup and clone this repo there)
	@ansible-playbook -i inventory/hosts.ini playbook_wsl.yml playbook_wsl_personal.yml $(runargs)

wsl-runtags:	## 🖥 Run WSL play tags
	@ansible-playbook -i inventory/hosts.ini --tags "$(runargs)" -e "$(runargs)=true" playbook_wsl.yml playbook_wsl_personal.yml
