#######
# WSL #
#######

wsl:
	@ansible-playbook -i inventory/hosts.ini main.yml --limit wsl

wsl-v:
	@ansible-playbook -i inventory/hosts.ini -vvv main.yml --limit wsl
