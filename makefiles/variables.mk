.PHONY: list-tags list-vars decrypt encrypt

# Let's allow the user to edit ansible vaults in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
# Even though I've got the git commit hook in place, when the repo name changes for example, and repo is cloned fresh, this poses a problem when forgetting to run `make setup` first and deploying the hook.
# This approach is just far safer than decrypting and encrypting the files themselves below.
edit-vault:	## 🔒 Edit ansible vaults in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
	ansible-vault edit group_vars/all/vault

edit-inventory:	## 🔒 Edit ansible inventory in-place instead of flat out decrypting it to reduce risk of pushing it in cleartext to remote repo.
	ansible-vault edit inventory/hosts.ini

decrypt:	## 🔒 Decrypt vaulted items (requires stored password)
	ansible-vault decrypt group_vars/all/vault inventory/hosts.ini

encrypt:	## 🔒 Encrypt vaulted items (requires stored password)
	ansible-vault encrypt group_vars/all/vault inventory/hosts.ini

list-vars:	## 🔒 List variables
	@$(CURDIR)/bin/vars_list.py vars/config.yml group_vars/all/vault.yml $(runargs)

list-tags:	## 🔒 List the available tags that you can run standalone from the playbook
	@grep 'tags:' playbook_*.yml | grep -v always | awk -F\" '{print $$2}'
