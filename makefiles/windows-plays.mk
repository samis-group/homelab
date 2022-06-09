###########
# Windows #
###########

windows:
	@ansible-playbook -i inventory/hosts.ini playbook_windows.yml $(runargs)

windows-v:
	@ansible-playbook -i inventory/hosts.ini -vvv playbook_windows.yml $(runargs)

windows-runtags:
	@ansible-playbook -i inventory/hosts.ini --tags "$(runargs)" -e "$(runargs)=true" main.yml --limit windows

windows-test:
	@ansible-playbook -i inventory/hosts.ini --tags "test_task" -e "test_task=true" main.yml --limit windows

windows-test-v:
	@ansible-playbook -i inventory/hosts.ini --tags "test_task" -e "test_task=true" main.yml --limit windows

windows-chocolatey:
	@ansible-playbook -i inventory/hosts.ini --tags "chocolatey" -e "chocolatey=true" main.yml --limit windows
