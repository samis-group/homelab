.PHONY: execute execute-v test test-v test-vvv

# Default make target specified here
.DEFAULT_GOAL := execute

# This grabs the passed arguments and stores them in make variable `runargs`
# So we can use them in any make target (even includes)
runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
$(eval $(runargs):;@true)

##############################################
### Main operation when only `make` is run ###
##############################################

# Run the playbook (Assumes `make setup` has already been run, If not, go do that first).
# Note: Vault password file directive is now specified in 'ansible.cfg'.
execute: proxmox k3s wsl windows	# Update these targets based on your deployment needs, this is my current stack

# Verbose option
execute-v:
	@ansible-playbook -i inventory/hosts.ini -vvv main.yml $(runargs)

##########################################################################
# This will make everything from absolutely nothing but debian machines. #
#        You must have setup authorized keys and can ssh to them         #
##########################################################################

from-scratch:
	@ansible-playbook -i inventory/hosts.ini main.yml $(runargs)

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
