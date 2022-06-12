#######
# LXC #
#######

.PHONY: lxc lxc-run-tags lxc-run-tags-v

lxc:	## 📦 LXC configuration playbook
	@ansible-playbook -i inventory/hosts.ini playbook_lxc.yml $(runargs)

lxc-run-tags:	## 🐳 Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_lxc.yml

lxc-run-tags-v:	## 🐳 VERBOSE - Same as above
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_lxc.yml
