.PHONY: execute execute-v test test-v test-vvv

# Default make target specified here
.DEFAULT_GOAL := execute

# Check if running as root, omit `sudo` from make targets if that is the case.
ifneq ($(shell id -u), 0)
    DO_SUDO = 'sudo'
else
    DO_SUDO = ''
endif

# This grabs the passed arguments and stores them in make variable `runargs`
# So we can use them in any make target (even includes)
runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
$(eval $(runargs):;@true)

##############################################
### Main operation when only `make` is run ###
##############################################

# Run the playbook (Assumes `make setup` has already been run, If not, go do that first).
# Note: Vault password file directive is now specified in 'ansible.cfg'.
# Update this default target with the targets you wish to deploy. This is my current stack.
execute: proxmox docker wsl windows

# Make absolutely everything in main.yml
everything:
	@ansible-playbook -i inventory/hosts.ini main.yml $(runargs)

##########################################################################
# This will make everything from absolutely nothing but debian machines. #
#        You must have setup authorized keys and can ssh to them         #
##########################################################################

from-scratch:
	@ansible-playbook -i inventory/hosts.ini main.yml $(runargs)

build-docker:
	@if [ ! -z $${VAULT_PASS} ]; then\
		docker build --no-cache -t homelab-ansible --build-arg VAULT_PASS=$${VAULT_PASS} .;\
	fi

build-docker-cache:
	@if [ ! -z $${VAULT_PASS} ]; then\
		docker build -t homelab-ansible --build-arg VAULT_PASS=$${VAULT_PASS} .;\
	fi

build-docker-shell:
	@docker run --rm -it -v "~/.ssh:/root/.ssh" homelab-ansible

##############
# Test Tasks #
##############

# Run the test playbook
test:
	@ansible-playbook -i inventory/hosts.ini playbook_test.yml $(runargs)

###################################
### Include all other makefiles ###
###################################

include makefiles/*.mk
