###########
# Windows #
###########

windows:	## 🖥 Main Windows play
	@ansible-playbook -i inventory/hosts.ini playbook_windows.yml $(runargs)

windows-runtags:	## 🖥 Run windows play tags
	@ansible-playbook -i inventory/hosts.ini --tags "$(runargs)" -e "$(runargs)=true" playbook_windows.yml

windows-chocolatey:	## 🖥 Run chocolatey tasks
	@ansible-playbook -i inventory/hosts.ini --tags "chocolatey" -e "chocolatey=true" playbook_windows.yml
