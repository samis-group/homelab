# Let's allow the user to edit ansible vaults in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
# Even though I've got the git commit hook in place, when the repo name changes for example, and repo is cloned fresh, this poses a problem when forgetting to run `make setup` first and deploying the hook.
# This approach is just far safer than decrypting and encrypting the files themselves below.
edit-vault:
	ansible-vault edit vars/vault.yml
edit-inventory:
	ansible-vault edit inventory/hosts.ini

# Decrypt all files in this repo
decrypt:
	ansible-vault decrypt vars/vault.yml inventory/hosts.ini

# Encrypt all files in this repo
encrypt:
	ansible-vault encrypt vars/vault.yml inventory/hosts.ini

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
