#######
# k3s #
#######

.PHONY: k3s k3s-v k3s-run-tags k3s-run-tags-v

k3s:
	@ansible-playbook -i inventory/hosts.ini playbook_k3s.yml

k3s-v:
	@ansible-playbook -i inventory/hosts.ini playbook_k3s.yml -vvv

# Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
k3s-run-tags:
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_k3s.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
k3s-run-tags-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_k3s.yml
