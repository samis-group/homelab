.PHONY: execute execute-v test test-v test-vvv run-tags run-tags-v provision-vm provision-vm-v update-compose update-compose-v setup-containers setup-containers-v list-tags list-vars setup apt pip reqs store-password githook decrypt encrypt

# Run the playbook (Assumes 'make setup' has been run)
execute:
	@ansible-playbook --vault-password-file ~/.ansible/password main.yml

execute-v:
	@ansible-playbook -vvv --vault-password-file ~/.ansible/password main.yml

# Run the test task for testing in
test:
	@ansible-playbook --tags "test_task" -e "test_task=true" --vault-password-file ~/.ansible/password main.yml

test-v:
	@ansible-playbook -v --tags "test_task" -e "test_task=true" --vault-password-file ~/.ansible/password main.yml

test-vvv:
	@ansible-playbook -vvv --tags "test_task" -e "test_task=true" --vault-password-file ~/.ansible/password main.yml

# Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags:
	@ansible-playbook --tags $(runargs) --vault-password-file ~/.ansible/password main.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags-v, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags-v:
	@ansible-playbook -vvv --tags $(runargs) --vault-password-file ~/.ansible/password main.yml

provision-vm:
	@ansible-playbook --vault-password-file ~/.ansible/password provision_vm.yml

provision-vm-v:
	@ansible-playbook -vvv --vault-password-file ~/.ansible/password provision_vm.yml

update-compose:
	@ansible-playbook --tags "update_compose" -e "update_compose=true" --vault-password-file ~/.ansible/password main.yml

update-compose-v:
	@ansible-playbook -vvv --tags "update_compose" -e "update_compose=true" --vault-password-file ~/.ansible/password main.yml

copy-files:
	@ansible-playbook --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" --vault-password-file ~/.ansible/password main.yml

copy-files-v:
	@ansible-playbook -vvv --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" --vault-password-file ~/.ansible/password main.yml

setup-containers:
	@ansible-playbook --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" --vault-password-file ~/.ansible/password main.yml

setup-containers-v:
	@ansible-playbook -vvv --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" --vault-password-file ~/.ansible/password main.yml

# List the available tags that you can run standalone from the playbook
list-tags:
	@grep 'tags:' main.yml | grep -v always | awk -F\" '{print $$2}'

# List variables
ifeq (list-vars, $(firstword $(MAKECMDGOALS)))
  extrafiles := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(extrafiles):;@true)
endif
list-vars:
	@./bin/vars_list.py group_vars/all.yml vars/default_config.yml vars/config.yml inventory $(extrafiles)

# Setup entire environment
setup: apt pip reqs store-password githook

# Ensure python and pip (assumes ubuntu host)
apt:
	@sudo apt install python3-pip

# Install python module requirements via requirements.txt file
pip:
	@sudo pip3 install --upgrade pip
	@sudo pip3 install -r requirements.txt

# install requirements.yml file
reqs:
	@ansible-galaxy install -r requirements.yml
	@ansible-galaxy install -r roles/requirements.yml

# Store your password for use with the playbook commands and if the vault is encrypted
# Python is just 1000% better at parsing raw data than bash/GNU Make. /rant
store-password:
	@red=`tput setaf 1`
	@green=`tput setaf 2`
	@reset=`tput sgr0`
	@if [ -n "$${VAULT_PASS}" ]; then\
		if [ ! -d ~/.ansible ]; then\
			mkdir ~/.ansible;\
		fi;\
		echo "$${VAULT_PASS}" > ~/.ansible/password;\
		if [ ! "$${VAULT_PASS}" = "$$(cat ~/.ansible/password)" ]; then\
			echo "$$(tput setaf 1)PASSWORD WAS NOT ABLE TO UPDATE! Please manually invoke the custom python script to do this for you as follows:";\
			echo "./bin/parse_pass.py 'super_secret_password' <- Make sure to use single quotes.$$(tput sgr0)";\
		else\
			echo "$$(tput setaf 2)PASSWORD SUCCESSFULLY STORED IN '~/.ansible/password'!$$(tput sgr0)";\
		fi;\
	fi

# Creates a pre-commit webhook so that you don't accidentally commit decrypted vault upstream
githook:
	@./bin/git_init.sh

# Let's allow the user to edit the ansible vaults in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
# Even though I've got the git commit hook in place, when the repo name changes for example, and repo is cloned fresh, this poses a problem when forgetting to run `make setup` first and deploying the hook.
# This approach is just far safer than decrypting and encrypting the files themselves below.
edit-vars-all:
	ansible-vault edit --vault-password-file ~/.ansible/password group_vars/all.yml

edit-vars-inventory:
	ansible-vault edit --vault-password-file ~/.ansible/password inventory

# Decrypt all files in this repo
decrypt:
	ansible-vault decrypt --vault-password-file ~/.ansible/password group_vars/all.yml
	ansible-vault decrypt --vault-password-file ~/.ansible/password inventory
	@# ansible-vault decrypt --vault-password-file ~/.ansible/password docker_vm_vars.yml

# Encrypt all files in this repo
encrypt:
	ansible-vault encrypt --vault-password-file ~/.ansible/password group_vars/all.yml
	ansible-vault encrypt --vault-password-file ~/.ansible/password inventory
	@# ansible-vault encrypt --vault-password-file ~/.ansible/password docker_vm_vars.yml
