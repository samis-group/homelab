.PHONY: execute everything test 

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

#-----------------------------------------
# Main operation when only `make` is run -
#-----------------------------------------

# Default make target specified here
.DEFAULT_GOAL := execute

# Run the playbook (Assumes `make setup` has already been run, If not, go do that first).
# Note: Vault password file directive is now specified in 'ansible.cfg'.
# Update this default target with the targets you wish to deploy. This is my current stack.
execute: proxmox docker wsl windows

#-------------------------------------------------------------------------
# This will make everything from absolutely nothing but debian machines. -
#        You must have setup authorized keys and can ssh to them         -
#-------------------------------------------------------------------------

everything:
	@ansible-playbook -i inventory/hosts.ini main.yml $(runargs)

#-----------------------------
# Docker build and run tasks -
#-----------------------------

USERID = $(shell id -u)

docker_build_cmd = \
	docker build -t homelab \
	--build-arg UID=$(USERID)

# If `.vault-password` file exists, source the password from it (helps with local build tests), else see if `VAULT_PASS` env var exists.
build-docker:
	@${docker_build_cmd} .

# If `.vault-password` file exists, source the password from it (helps with local build tests), else see if `VAULT_PASS` env var exists.
build-docker-no-cache:
	@${docker_build_cmd} --no-cache .

# Check if VAULT_PASS is set, and pass through to container, otherwise don't and let stdin in the parse_pass python script, ask for it.
ifeq ($(origin VAULT_PASS),undefined)
    DO_VAULT_PASS =
else
    DO_VAULT_PASS = --env VAULT_PASS="${VAULT_PASS}"
endif

docker_run_cmd = \
	docker run --rm -it $(DO_VAULT_PASS) \
	--volume "${PWD}:/ansible/repo" \
	--volume "${HOME}/.ssh/:/home/ubuntu/.ssh" \
	--user=$(USERID)

docker_dotfiles = --volume "${HOME}/dotfiles:/home/ubuntu/dotfiles"

local_container_name = homelab
registry_container_name = registry.gitlab.com/sami-group/homelab

run-docker-registry:
	@${docker_run_cmd} \
	${registry_container_name}

run-docker-registry-dotfiles:
	@${docker_run_cmd} \
	${docker_dotfiles} \
	${registry_container_name}

run-docker-local: build-docker
	${docker_run_cmd} \
	${local_container_name}

run-docker-local-dotfiles: build-docker
	@${docker_run_cmd} \
	${docker_dotfiles} \
	${local_container_name}

reqs-docker:
	@ansible-galaxy install -r requirements.yml -p /ansible/collections/ansible_collections
	@ansible-galaxy install -r roles/requirements.yml

#--------------
# Setup Tasks -
#--------------

.PHONY: setup apt pip reqs store-password githook

# Setup entire environment
setup: apt pip reqs store-password githook

# Ensure python and pip (assumes ubuntu host)
apt:
	${DO_SUDO} apt install python3-pip

# Install python module requirements via requirements.txt file
pip:
	${DO_SUDO} pip3 install --upgrade pip
	${DO_SUDO} pip3 install --ignore-installed -r requirements.txt

# install requirements.yml file
reqs:
	@ansible-galaxy install -r requirements.yml
	@ansible-galaxy install -r roles/requirements.yml

# Store your password if the vault is encrypted
# Python is just 1000% better at parsing raw data than bash/GNU Make. /rant
store-password:
	@./bin/parse_pass.py

# Creates a pre-commit webhook so that you don't accidentally commit decrypted vault upstream
githook:
	@if [ -d .git/ ]; then\
		if [ -e .git/hooks/pre-commit ]; then\
			echo "$$(tput setaf 2)Removing Existing pre-commit hook...$$(tput sgr0)";\
	  	rm .git/hooks/pre-commit;\
		fi;\
  fi
	@cp bin/git-vault-check.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "$$(tput setaf 2)Githook Deployed!$$(tput sgr0)"

#----------
# Linters -
#----------

yamllint:
	yamllint -f parsable .

# Diagnostic output; useful when run in a git hook
_start-check:
	@echo 'Running "make check"'

# Run all tests and linters
check lint: _start-check yamllint
	@echo '**** LGTM! ****'

#-------------
# Test Tasks -
#-------------

# Run the test playbook
test:
	@ansible-playbook -i inventory/hosts.ini playbook_test.yml $(runargs)

#------------------------------
# Include all other makefiles -
#------------------------------

include makefiles/*.mk
