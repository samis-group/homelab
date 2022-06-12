###########
# Windows #
###########

windows:	## 🖥 Main Windows play
	@ansible-playbook -i inventory/hosts.ini playbook_windows.yml $(runargs)

windows-runtags:	## 🖥 Run windows play tags
	@ansible-playbook -i inventory/hosts.ini --tags "$(runargs)" -e "$(runargs)=true" main.yml --limit windows

windows-test:	## 🖥 Run test_task on 'windows' hosts
	@ansible-playbook -i inventory/hosts.ini --tags "test_task" -e "test_task=true" main.yml --limit windows $(runargs)

windows-chocolatey:	## 🖥 Run chocolatey tasks
	@ansible-playbook -i inventory/hosts.ini --tags "chocolatey" -e "chocolatey=true" main.yml --limit windows
