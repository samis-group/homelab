.PHONY: execute execute-v test test-v test-vvv run-tags run-tags-v provision-vm provision-vm-v update-compose update-compose-v setup-containers setup-containers-v list-tags list-vars setup apt pip reqs store-password githook decrypt encrypt

##############################################
### Main operation when only `make` is run ###
##############################################

# Run the playbook (Assumes `make setup` has already been run, If not, go do that first).
# Note: Vault password file directive is now specified in 'ansible.cfg'.
execute:
	@ansible-playbook -i inventory/hosts.ini main.yml

execute-v:
	@ansible-playbook -i inventory/hosts.ini -vvv main.yml

###################################
### Include all other makefiles ###
###################################

include makefiles/*.mk
