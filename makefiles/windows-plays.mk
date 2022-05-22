###########
# Windows #
###########

windows:
	@ansible-playbook -i inventory/hosts.ini main.yml --limit win10ssh

windows-v:
	@ansible-playbook -i inventory/hosts.ini -vvv main.yml --limit win10ssh

windows-test:
	@ansible-playbook -i inventory/hosts.ini --tags "test_task" -e "test_task=true" main.yml --limit win10ssh

windows-test-v:
	@ansible-playbook -i inventory/hosts.ini --tags "test_task" -e "test_task=true" main.yml --limit win10ssh

windows-chocolatey:
	@ansible-playbook -i inventory/hosts.ini --tags "chocolatey" -e "chocolatey=true" main.yml --limit win10ssh
