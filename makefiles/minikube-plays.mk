############
# minikube #
############
.PHONY: minikube

minikube:	## ☸ Main minikube play
	@ansible-playbook -i inventory/hosts.ini playbook_minikube.yml $(runargs)
