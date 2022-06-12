##########
# Docker #
##########
.PHONY: update-compose update-compose-v setup-containers setup-containers-v

docker:	## 🐳 Main docker play
	@ansible-playbook -i inventory/hosts.ini playbook_docker.yml $(runargs)

docker-update-compose:	## 🐳 Updated docker-compose files
	@ansible-playbook -i inventory/hosts.ini --tags "update_compose" -e "update_compose=true" playbook_docker.yml $(runargs)

docker-copy-files:	## 🐳 Copy docker files to docker vm
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml $(runargs)

docker-setup-containers:	## 🐳 Run setup docker containers tasks
	@ansible-playbook -i inventory/hosts.ini --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" playbook_docker.yml $(runargs)

docker-run-tags:	## 🐳 Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_docker.yml

docker-run-tags-v:	## 🐳 VERBOSE - Same as above
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_docker.yml

docker-restore-containers:	## 🐳 Restore docker container data from backups on NFS share - Pass the inventory_hostname/group_names of the item you want to run this on
	@echo "WARNING - This is going to restore the containers in place of whatever is there currently. Press any key to continue..."; \
	read break;
	ansible-playbook -i inventory/hosts.ini --tags "restore_docker_data" -e "restore_docker_data=true" playbook_docker.yml --limit $(runargs)
