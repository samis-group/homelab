# ##########################################################################
# # This will make everything from absolutely nothing but debian machines. #
# ##########################################################################
# from-scratch:
# 	@

##############
# Test Tasks #
##############

# Run the test playbook
test:
	@ansible-playbook -i inventory/hosts.ini playbook_test.yml

test-v:
	@ansible-playbook -i inventory/hosts.ini -v playbook_test.yml

test-vvv:
	@ansible-playbook -i inventory/hosts.ini -vvv playbook_test.yml

# Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags:
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_docker.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags-v, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_docker.yml

###########
# Proxmox #
###########

proxmox:
	@ansible-playbook -i inventory/hosts.ini playbook_proxmox.yml

proxmox-v:
	@ansible-playbook -vvv -i inventory/hosts.ini playbook_proxmox.yml

##########
# Docker #
##########

docker:
	@ansible-playbook -i inventory/hosts.ini playbook_docker.yml

docker-v:
	@ansible-playbook -i inventory/hosts.ini playbook_docker.yml -vvv

update-compose:
	@ansible-playbook -i inventory/hosts.ini --tags "update_compose" -e "update_compose=true" playbook_docker.yml

update-compose-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "update_compose" -e "update_compose=true" playbook_docker.yml

copy-files:
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

copy-files-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

setup-containers:
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

setup-containers-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

#######
# WSL #
#######

wsl:
	@ansible-playbook -i inventory/hosts.ini playbook_wsl.yml

wsl-v:
	@ansible-playbook -i inventory/hosts.ini -vvv playbook_wsl.yml

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
