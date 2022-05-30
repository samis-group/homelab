##########
# Docker #
##########
.PHONY: update-compose update-compose-v setup-containers setup-containers-v

docker:
	@ansible-playbook -i inventory/hosts.ini main.yml --limit docker

docker-v:
	@ansible-playbook -i inventory/hosts.ini main.yml --limit docker -vvv

docker-update-compose:
	@ansible-playbook -i inventory/hosts.ini --tags "update_compose" -e "update_compose=true" playbook_docker.yml

docker-update-compose-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "update_compose" -e "update_compose=true" playbook_docker.yml

docker-copy-files:
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

docker-copy-files-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

docker-setup-containers:
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

docker-setup-containers-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml

# Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
docker-run-tags:
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_docker.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
docker-run-tags-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_docker.yml

# Pass the inventory_hostname/group_names of the item you want to run this on
docker-restore-containers:
	@echo "WARNING - This is going to restore the containers in place of whatever is there currently. Press any key to continue..."; \
	read break;
	ansible-playbook -i inventory/hosts.ini --tags "restore_docker_data" -e "restore_docker_data=true" playbook_docker.yml --limit $(runargs)
