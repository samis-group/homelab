# ##########################################################################
# # This will make everything from absolutely nothing but debian machines. #
# ##########################################################################
# from-scratch:
# 	@

##############
# Test Tasks #
##############

# Run the test task for testing in
test:
	@ansible-playbook -i inventory/hosts.ini --tags "test_task" -e "test_task=true" main.yml

test-v:
	@ansible-playbook -i inventory/hosts.ini -v --tags "test_task" -e "test_task=true" main.yml

test-vvv:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "test_task" -e "test_task=true" main.yml

# Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags:
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) main.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags-v, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) main.yml

###########
# Proxmox #
###########

# TBD..

# provision-vms:
# 	@ansible-playbook -i inventory/hosts.ini --limit proxmox

# provision-vms-v:
# 	@ansible-playbook -i inventory/hosts.ini -vvv --limit proxmox

##########
# Docker #
##########

docker:
	@ansible-playbook -i inventory/hosts.ini main.yml --limit docker

docker-v:
	@ansible-playbook -i inventory/hosts.ini main.yml -vvv --limit docker

update-compose:
	@ansible-playbook -i inventory/hosts.ini --tags "update_compose" -e "update_compose=true" main.yml --limit docker

update-compose-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "update_compose" -e "update_compose=true" main.yml --limit docker

copy-files:
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" main.yml --limit docker

copy-files-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" main.yml --limit docker

setup-containers:
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" main.yml --limit docker

setup-containers-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" main.yml --limit docker

#######
# WSL #
#######

wsl:
	@ansible-playbook -i inventory/hosts.ini main.yml --limit wsl

wsl-v:
	@ansible-playbook -i inventory/hosts.ini -vvv main.yml --limit wsl

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

chocolatey:
	@ansible-playbook -i inventory/hosts.ini --tags "chocolatey" -e "chocolatey=true" main.yml --limit win10ssh
