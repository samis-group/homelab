.PHONY: execute execute-v test test-v test-vvv run-tags run-tags-v provision-vm provision-vm-v update-compose update-compose-v setup-containers setup-containers-v list-tags list-vars setup apt pip reqs store-password githook decrypt encrypt

# Run the playbook (Assumes 'make setup' has been run). Note: Vault password file directive is now specified in 'ansible.cfg'.
execute:
	@ansible-playbook main.yml

execute-v:
	@ansible-playbook -vvv main.yml

wsl:
	@ansible-playbook main.yml --limit wsl

wsl-v:
	@ansible-playbook -vvv main.yml --limit wsl

windows:
	@ansible-playbook main.yml --limit win10ssh

windows-v:
	@ansible-playbook -vvv main.yml --limit win10ssh

windows-test:
	@ansible-playbook --tags "test_task" -e "test_task=true" main.yml --limit win10ssh

windows-test-v:
	@ansible-playbook --tags "test_task" -e "test_task=true" main.yml --limit win10ssh

chocolatey:
	@ansible-playbook --tags "chocolatey" -e "chocolatey=true" main.yml --limit win10ssh

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
	@if [ -d .git/ ]; then\
		if [ -e .git/hooks/pre-commit ]; then\
			echo "$$(tput setaf 2)Removing Existing pre-commit...$$(tput sgr0)";\
	  	rm .git/hooks/pre-commit;\
		fi;\
  fi
	@cp bin/git-vault-check.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "$$(tput setaf 2)Githook Deployed!$$(tput sgr0)"

# List variables
ifeq (list-vars, $(firstword $(MAKECMDGOALS)))
  extrafiles := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(extrafiles):;@true)
endif
list-vars:
	@./bin/vars_list.py group_vars/all.yml vars/default_config.yml vars/config.yml vars/vault.yml $(extrafiles)

# List the available tags that you can run standalone from the playbook
list-tags:
	@grep 'tags:' main.yml | grep -v always | awk -F\" '{print $$2}'

# Run the test task for testing in
test:
	@ansible-playbook --tags "test_task" -e "test_task=true" main.yml

test-v:
	@ansible-playbook -v --tags "test_task" -e "test_task=true" main.yml

test-vvv:
	@ansible-playbook -vvv --tags "test_task" -e "test_task=true" main.yml

# Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags:
	@ansible-playbook --tags $(runargs) main.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
ifeq (run-tags-v, $(firstword $(MAKECMDGOALS)))
  runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(runargs):;@true)
endif
run-tags-v:
	@ansible-playbook -vvv --tags $(runargs) main.yml

provision-vm:
	@ansible-playbook provision_vm.yml

provision-vm-v:
	@ansible-playbook -vvv provision_vm.yml

update-compose:
	@ansible-playbook --tags "update_compose" -e "update_compose=true" main.yml

update-compose-v:
	@ansible-playbook -vvv --tags "update_compose" -e "update_compose=true" main.yml

copy-files:
	@ansible-playbook --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" main.yml

copy-files-v:
	@ansible-playbook -vvv --tags "copy_files,update_compose" -e "copy_files=true" -e "update_compose=true" main.yml

setup-containers:
	@ansible-playbook --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" main.yml

setup-containers-v:
	@ansible-playbook -vvv --tags "copy_files,update_compose,setup_containers" -e "copy_files=true" -e "update_compose=true" main.yml

# Let's allow the user to edit the ansible vaults in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
# Even though I've got the git commit hook in place, when the repo name changes for example, and repo is cloned fresh, this poses a problem when forgetting to run `make setup` first and deploying the hook.
# This approach is just far safer than decrypting and encrypting the files themselves below.
edit-vault:
	ansible-vault edit vars/vault.yml

# Decrypt all files in this repo
decrypt:
	ansible-vault decrypt vars/vault.yml

# Encrypt all files in this repo
encrypt:
	ansible-vault encrypt vars/vault.yml
