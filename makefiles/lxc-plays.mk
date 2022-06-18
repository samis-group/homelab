#######
# LXC #
#######

.PHONY: lxc lxc-run-tags lxc-run-tags-v

lxc:	## 📦 LXC configuration playbook
	@ansible-playbook -i inventory/hosts.ini playbook_lxc.yml $(runargs)

lxc-%:	## 📦 Pass the host/group that you want to run the tag for, into this target (Check 'playbook_lxc.yml' play tags for more information). e.g. `make lxc-gitlab_runner`
	ansible-playbook -i inventory/hosts.ini --tags $@ playbook_lxc.yml $(runargs)

lxc-run-tags:	## 📦 Run only the tags passed in separated by comma (e.g. make run-tags update_compose,logrotate)
	@ansible-playbook -i inventory/hosts.ini --tags $(runargs) playbook_lxc.yml

lxc-run-tags-v:	## 📦 VERBOSE - Same as above
	@ansible-playbook -i inventory/hosts.ini -vvv --tags $(runargs) playbook_lxc.yml

lxc-gitlab-runner:	## 📦 Make Gitlab Runner LXC (Ensure 'gitlab.runner_token' in vault (make edit-vault) is updated with your group runners (mine: https://gitlab.com/groups/sami-group/-/runners) )
	@ansible-playbook -i inventory/hosts.ini --tags lxc-gitlab_runner playbook_lxc.yml $(runargs)
