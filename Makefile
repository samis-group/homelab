.PHONY: execute execute-v test test-v test-vvv

# This grabs the passed arguments and stores them in make variable `runargs`
# So we can use them in any make target (even includes)
runargs := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
$(eval $(runargs):;@true)

##############################################
### Main operation when only `make` is run ###
##############################################

# Run the playbook (Assumes `make setup` has already been run, If not, go do that first).
# Note: Vault password file directive is now specified in 'ansible.cfg'.
execute:
	@ansible-playbook -i inventory/hosts.ini main.yml

# Verbose option
execute-v:
	@ansible-playbook -i inventory/hosts.ini -vvv main.yml

##########################################################################
# This will make everything from absolutely nothing but debian machines. #
#        You must have setup authorized keys and can ssh to them         #
##########################################################################
from-scratch:
	@ansible-playbook -i inventory/hosts.ini main.yml -e "create_vm_template=true"

##############
# Test Tasks #
##############

# Run the test playbook
test:
	@ansible-playbook -i inventory/hosts.ini playbook_test.yml

# Verbose option
test-v:
	@ansible-playbook -i inventory/hosts.ini -v playbook_test.yml

# Verboserer option
test-vvv:
	@ansible-playbook -i inventory/hosts.ini -vvv playbook_test.yml

###################################
### Include all other makefiles ###
###################################

include makefiles/*.mk
