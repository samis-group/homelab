#######
# k3s #
#######

.PHONY: k3s k3s-v k3s-run-tags k3s-run-tags-v

k3s:	## ☸ Main k3s play
	@ansible-playbook -i inventory/hosts.ini playbook_k3s.yml $(runargs)

k3s-run-tags:	## ☸ Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_k3s.yml

k3s-run-tags-v:	## ☸ VERBOSE - Same as above
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_k3s.yml

k3s-reset:	## ☸ Reset k3s stack from beginning of it's inception
	@ansible-playbook -i inventory/hosts.ini playbook_k3s_reset.yml $(runargs)

k3s-helm-charts:	## ☸ Deploy helm charts
	@ansible-playbook -i inventory/hosts.ini --tags "helm_charts" playbook_k3s.yml $(runargs)
