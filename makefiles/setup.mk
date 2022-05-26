.PHONY: setup apt pip reqs store-password githook

# Setup entire environment
setup: apt pip reqs store-password githook

# Ensure python and pip (assumes ubuntu host)
apt:
	@sudo apt install python3-pip

# Install python module requirements via requirements.txt file
pip:
	@sudo pip3 install --upgrade pip
	@sudo pip3 install -r requirements.txt

# install requirements.yml file
reqs:
	@ansible-galaxy install -r requirements.yml
	@ansible-galaxy install -r roles/requirements.yml

# Store your password for use with the playbook commands and if the vault is encrypted
# Python is just 1000% better at parsing raw data than bash/GNU Make. /rant
store-password:
	@red=`tput setaf 1`
	@green=`tput setaf 2`
	@reset=`tput sgr0`
	@if [ -n "$${VAULT_PASS}" ]; then\
		./bin/parse_pass.py "$${VAULT_PASS}";\
		if [ ! "$${VAULT_PASS}" = "$$(cat ./.vault-password)" ]; then\
			echo "$$(tput setaf 1)PASSWORD WAS NOT ABLE TO UPDATE! Please manually invoke the custom python script to do this for you as follows:";\
			echo "./bin/parse_pass.py 'super_secret_password' <- Make sure to use single quotes.$$(tput sgr0)";\
		else\
			echo "$$(tput setaf 2)PASSWORD SUCCESSFULLY STORED IN '.vault-password'!$$(tput sgr0)";\
		fi;\
	fi

# Creates a pre-commit webhook so that you don't accidentally commit decrypted vault upstream
githook:
	@if [ -d .git/ ]; then\
		if [ -e .git/hooks/pre-commit ]; then\
			echo "$$(tput setaf 2)Removing Existing pre-commit...$$(tput sgr0)";\
	  	rm .git/hooks/pre-commit;\
		fi;\
  fi
	@cp bin/git-vault-check.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "$$(tput setaf 2)Githook Deployed!$$(tput sgr0)"
