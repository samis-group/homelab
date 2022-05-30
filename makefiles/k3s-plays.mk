#######
# k3s #
#######

.PHONY: k3s k3s-v k3s-run-tags k3s-run-tags-v

k3s:
	@ansible-playbook -i inventory/hosts.ini playbook_k3s.yml $(runargs)

# Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
k3s-run-tags:
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_k3s.yml

# VERBOSE - Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
k3s-run-tags-v:
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_k3s.yml

# Reset k3s stack from beginning of it's inception
k3s-reset:
	@ansible-playbook -i inventory/hosts.ini playbook_k3s_reset.yml $(runargs)

# Deploy helm charts
k3s-helm-charts:
	@ansible-playbook -i inventory/hosts.ini --tags "helm_charts" playbook_k3s.yml $(runargs)
