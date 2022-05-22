##########
# Docker #
##########

docker:
	@ansible-playbook -i inventory/hosts.ini playbook_docker.yml

docker-v:
	@ansible-playbook -i inventory/hosts.ini playbook_docker.yml -vvv

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
ifeq (run-tags, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
docker-run-tags:
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_docker.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags-v, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
docker-run-tags-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_docker.yml
