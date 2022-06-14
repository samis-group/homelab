# Check if running as root, omit `sudo` from make targets if that is the case.
ifneq ($(shell id -u), 0)
    DO_SUDO = sudo
else
    DO_SUDO =
endif

# This grabs the passed arguments and stores them in make variable `runargs`
# So we can use them in any make target (even includes)
runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
$(eval $(runargs):;@true)

#----------------------#
# Main make operations #
#----------------------#

# Default make target specified here
.DEFAULT_GOAL := help

# Used below to indent the help list to a custom point (I like to line it up, thanks OCD)
help_indent = 28
.PHONY: help
help:	# 💬 This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | cut -d: -f2- | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-${help_indent}s\033[0m %s\n", $$1, $$2}'

.PHONY: execute
# Run the playbook (Assumes `make setup` has already been run, If not, go do that first).
# Note: Vault password file directive is now specified in 'ansible.cfg'.
# Update this default target with the targets you wish to deploy. This is my current stack.
execute: proxmox docker wsl windows	## 🔨 Execute my currently used playbooks/automations

#------------------------------------------------------------------------#
# This will make everything from absolutely nothing but debian machines. #
#        You must have setup authorized keys and can ssh to them         #
#------------------------------------------------------------------------#

.PHONY: everything
everything:	## 🔨 Make everything...
	@ansible-playbook -i inventory/hosts.ini main.yml $(runargs)

#----------------------------#
# Docker build and run tasks #
#----------------------------#

USERID = $(shell id -u)

docker_build_cmd = \
	docker build -t homelab \
	--build-arg UID=$(USERID)


build-docker:	## 🏗️🐳 Builds the docker image locally. If `.vault-password` file exists, source the password from it (helps with local build tests), else see if `VAULT_PASS` env var exists.
	@${docker_build_cmd} .

# If `.vault-password` file exists, source the password from it (helps with local build tests), else see if `VAULT_PASS` env var exists.
build-docker-no-cache:	## 🏗️🐳 Same as above but without cache
	@${docker_build_cmd} --no-cache .

# Check if VAULT_PASS is set, and pass through to container, otherwise don't and let stdin in the parse_pass python script, ask for it.
ifeq ($(origin VAULT_PASS),undefined)
    DO_VAULT_PASS =
else
    DO_VAULT_PASS = --env VAULT_PASS="${VAULT_PASS}"
endif

# Instantiate docker run cmd
docker_run_cmd = \
	docker run --rm -it $(DO_VAULT_PASS) \
	--volume "${PWD}:/ansible/repo" \
	--volume "${HOME}/.ssh/:/home/ubuntu/.ssh" \
	--user=$(USERID)

# Dotfiles volume bind mount var
docker_dotfiles = --volume "${HOME}/dotfiles:/home/ubuntu/dotfiles"

# Other vars
local_container_name = homelab
registry_container_name = registry.gitlab.com/sami-group/homelab

run-docker-registry:	## 🐳 Run the docker container from the public registry
	@${docker_run_cmd} \
	${registry_container_name}

run-docker-registry-dotfiles:	## 🐳 Run the docker container from the public registry with dotfiles volume mount (mainly personal)
	@${docker_run_cmd} \
	${docker_dotfiles} \
	${registry_container_name}

run-docker-local: build-docker	## 🐳 Run the docker container from the locally built image (also builds the image)
	${docker_run_cmd} \
	${local_container_name}

run-docker-local-dotfiles: build-docker	## 🐳 Run the docker container from the locally built image (also builds the image) with dotfiles volume mount (mainly personal)
	@${docker_run_cmd} \
	${docker_dotfiles} \
	${local_container_name}

reqs-docker:	## 🐳🚧 Install ansible galaxy requirements
	@ansible-galaxy install -r requirements.yml -p /ansible/collections/ansible_collections
	@ansible-galaxy install -r roles/requirements.yml

#-------------#
# Setup Tasks #
#-------------#

.PHONY: setup apt pip reqs store-password githook

# Setup entire environment
setup: apt pip reqs store-password githook	## 🚧 Run setup tasks like apt, pip requirements, store-password and githook (below)

apt:	## 🚧 install apt requirements on the local system
	${DO_SUDO} apt install python3-pip

pip:	## 🚧 Install python module requirements via requirements.txt file
	${DO_SUDO} pip3 install --upgrade pip
	${DO_SUDO} pip3 install --ignore-installed -r requirements.txt

reqs:	## 🚧 sinstall requirements.yml and roles/requirements.yml files
	@ansible-galaxy install -r requirements.yml
	@ansible-galaxy install -r roles/requirements.yml

# Python is just 1000% better at parsing raw data than bash/GNU Make. /rant
store-password:	## 🚧 Store your password if the vault is encrypted
	@./bin/parse_pass.py

githook:	## 🚧 Creates a pre-commit webhook so that you don't accidentally commit decrypted vault upstream
	@if [ -d .git/ ]; then\
		if [ -e .git/hooks/pre-commit ]; then\
			echo "$$(tput setaf 2)Removing Existing pre-commit hook...$$(tput sgr0)";\
	  	rm .git/hooks/pre-commit;\
		fi;\
  fi
	@cp bin/git-vault-check.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "$$(tput setaf 2)Githook Deployed!$$(tput sgr0)"

vagrant-setup:	## 🚧 Add generic/ubuntu2004 box to vagrant (assumes vagrant is installed already, run `make wsl` to do so)
	@vagrant box add generic/ubuntu2004

#---------------------------#
# Vault and Variables Tasks #
#---------------------------#

.PHONY: list-tags list-vars decrypt encrypt

# Let's allow the user to edit ansible vaults in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
# Even though I've got the git commit hook in place, when the repo name changes for example, and repo is cloned fresh, this poses a problem when forgetting to run `make setup` first and deploying the hook.
# This approach is just far safer than decrypting and encrypting the files themselves below.
edit-vault:	## 🔒 Edit ansible vaults in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
	ansible-vault edit group_vars/all/vault.yml

edit-inventory:	## 🔒 Edit ansible inventory in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
	ansible-vault edit inventory/hosts.ini

decrypt:	## 🔒 Decrypt vaulted items (requires stored password)
	ansible-vault decrypt group_vars/all/vault.yml inventory/hosts.ini

encrypt:	## 🔒 Encrypt vaulted items (requires stored password)
	ansible-vault encrypt group_vars/all/vault.yml inventory/hosts.ini

list-vars:	## 🔒 List variables
	@$(CURDIR)/bin/vars_list.py vars/config.yml group_vars/all/vault.yml $(runargs)

list-tags:	## 🔒 List the available tags that you can run standalone from the playbook
	@grep 'tags:' playbook_*.yml | grep -v always | awk -F\" '{print $$2}'

#---------#
# Linters #
#---------#

check lint: _start-check yamllint	## 🔎 Run all tests, Linters & formatters (currently will not fix but sets exit code on error)
	@echo '**** LGTM! ****'

_start-check:	# Diagnostic output; useful when run in a git hook
	@echo 'Running "make check / make lint"'

yamllint:	# Currently the only one.. will add more targets in the future.
	yamllint -f parsable .

#------------#
# Test Tasks #
#------------#

.PHONY: test
test:	## 🧪 Run the test playbook
	@ansible-playbook -i inventory/hosts.ini playbook_test.yml $(runargs)

#-----------------------------#
# Include all other makefiles #
#-----------------------------#

include makefiles/*.mk
