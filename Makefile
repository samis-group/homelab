# Default make target specified here
.DEFAULT_GOAL := setup

# Command Varaibles
docker_run_cmd = docker run
docker_flags := -d 
compose_flags := 

cleanup:
	@docker stop $(shell docker ps -a -q)
	@docker remove $(shell docker ps -a -q)

##########################
### Define Images Here ###
##########################

### homelab-workstation ###
homelab-workstation: export name=homelab-workstation_local
homelab-workstation: export docker_flags= -d -v "${PWD}/docker/$*/assets:/assets" 
homelab-workstation: build-docker-homelab-workstation run-docker-homelab-workstation
# Shell
homelab-workstation-shell: name=homelab-workstation_local
homelab-workstation-shell: docker_flags= -v "${PWD}/docker/$*/assets:/assets" 
homelab-workstation-shell: shell=/bin/bash
homelab-workstation-shell: run-docker-shell-homelab-workstation
# Remove
homelab-workstation-rm: export name=homelab-workstation_local
homelab-workstation-rm: rm-homelab-workstation

### actions-runner-base ###
actions-runner-base: export name=actions-runner-base_local
actions-runner-base: export docker_flags= -d -v "${PWD}/docker/$*/assets:/assets" 
actions-runner-base: build-docker-actions-runner-base run-docker-actions-runner-base
# Shell
actions-runner-base-shell: name=actions-runner-base_local
actions-runner-base-shell: docker_flags= -v "${PWD}/docker/$*/assets:/assets" 
actions-runner-base-shell: shell=/bin/bash
actions-runner-base-shell: run-docker-shell-actions-runner-base
# Remove
actions-runner-base-rm: export name=actions-runner-base_local
actions-runner-base-rm: rm-actions-runner-base

########################
### Reusable targets ###
########################

run-docker-%:
	${docker_run_cmd} $(docker_flags) --name $(name) $(if $(strip $(image_name)), $(image_name), $(name))

build-docker-%:
	docker build -t $(name) -f docker/$*/Dockerfile --build-context project=./ docker/$*

build-docker-dev-%:
	docker build --target=dev -t $(name) -f docker/$*/Dockerfile --build-context project=./ docker/$*

build-docker-prod-%:
	docker build --target=prod -t $(name) -f docker/$*/Dockerfile --build-context project=./ docker/$*

build-docker-no-cache-%:
	docker build --no-cache -t $(name) -f docker/$*/Dockerfile --build-context project=./ docker/$*

what-is-url:
	@echo "!!! Go here dummy --> http://localhost:$(local_port)/ !!!"

exec-command-%:
	@docker exec -it $(name) $(exec_command)

# Make a brand new container from the base image and enter shell (Useful for dev in docker containers)
run-docker-shell-%: build-docker-%
	${docker_run_cmd} $(docker_flags) --rm -it --name $(name) --entrypoint=$(shell) $(if $(strip $(image_name)), $(image_name), $(name))

compose-up-%:
	@docker compose $(compose_flags) -f docker/$*/docker-compose.yml up -d

compose-down-%:
	@docker compose -f docker/$*/docker-compose.yml down

rm-%:
	@docker stop $(name)
	@docker rm $(name)

rm-image-%:
	@docker image rm $(name)

##################################
### Container Specific targets ###
##################################

setup-api:
	@sudo apt install -y npm
	@cd app && npm install

ozbargain-env-setup:
	@ENV_FILE="${PWD}/docker/ozbargain-bot/.env";\
	if [ ! -e "$${ENV_FILE}" ]; then\
		touch "$${ENV_FILE}";\
		read -p "slack webhook (leave blank if n/a): " OZBARGAIN_SLACK_WEBHOOK;\
		if ! [ -z "$${OZBARGAIN_SLACK_WEBHOOK}" ]; then\
			echo "Writing OZBARGAIN_SLACK_WEBHOOK...";\
			sed -i '/OZBARGAIN_SLACK_WEBHOOK=/d' $${ENV_FILE};\
			echo "OZBARGAIN_SLACK_WEBHOOK=$${OZBARGAIN_SLACK_WEBHOOK}" >> "$${ENV_FILE}";\
		fi;\
		read -p "slack_frontpage webhook (leave blank if n/a): " OZBARGAIN_SLACK_WEBHOOK_FRONTPAGE;\
		if ! [ -z "$${OZBARGAIN_SLACK_WEBHOOK_FRONTPAGE}" ]; then\
			echo "Writing OZBARGAIN_SLACK_WEBHOOK_FRONTPAGE...";\
			sed -i '/OZBARGAIN_SLACK_WEBHOOK_FRONTPAGE=/d' $${ENV_FILE};\
			echo "OZBARGAIN_SLACK_WEBHOOK_FRONTPAGE=$${OZBARGAIN_SLACK_WEBHOOK_FRONTPAGE}" >> "$${ENV_FILE}";\
		fi;\
		read -p "discord webhook (leave blank if n/a): " OZBARGAIN_DISCORD_WEBHOOK;\
		if ! [ -z "$${OZBARGAIN_DISCORD_WEBHOOK}" ]; then\
			echo "Writing OZBARGAIN_DISCORD_WEBHOOK...";\
			sed -i '/OZBARGAIN_DISCORD_WEBHOOK=/d' $${ENV_FILE};\
			echo "OZBARGAIN_DISCORD_WEBHOOK=$${OZBARGAIN_DISCORD_WEBHOOK}" >> "$${ENV_FILE}";\
		fi;\
		read -p "discord_frontpage webhook (leave blank if n/a): " OZBARGAIN_DISCORD_WEBHOOK_FRONTPAGE;\
		if ! [ -z "$${OZBARGAIN_DISCORD_WEBHOOK_FRONTPAGE}" ]; then\
			echo "Writing OZBARGAIN_DISCORD_WEBHOOK_FRONTPAGE...";\
			sed -i '/OZBARGAIN_DISCORD_WEBHOOK_FRONTPAGE=/d' $${ENV_FILE};\
			echo "OZBARGAIN_DISCORD_WEBHOOK_FRONTPAGE=$${OZBARGAIN_DISCORD_WEBHOOK_FRONTPAGE}" >> "$${ENV_FILE}";\
		fi;\
		read -p "Verbose (true/false - leave blank if n/a): " OZBARGAIN_VERBOSE;\
		if ! [ -z "$${OZBARGAIN_VERBOSE}" ]; then\
			echo "Writing OZBARGAIN_VERBOSE...";\
			sed -i '/OZBARGAIN_VERBOSE=/d' $${ENV_FILE};\
			echo "OZBARGAIN_VERBOSE=$${OZBARGAIN_VERBOSE}" >> "$${ENV_FILE}";\
		fi;\
		read -p "Timestamp Override (integer - do you want to override the timestamp that is set on each 5 min interval, useful for testing - leave blank if n/a): " OZBARGAIN_TIMESTAMP_OVERRIDE;\
		if ! [ -z "$${OZBARGAIN_TIMESTAMP_OVERRIDE}" ]; then\
			echo "Writing OZBARGAIN_TIMESTAMP_OVERRIDE...";\
			sed -i '/OZBARGAIN_TIMESTAMP_OVERRIDE=/d' $${ENV_FILE};\
			echo "OZBARGAIN_TIMESTAMP_OVERRIDE=$${OZBARGAIN_TIMESTAMP_OVERRIDE}" >> "$${ENV_FILE}";\
		fi;\
		read -p "Run on container boot as well as cron (<any user input = true> - Run the script on initial container boot as well as cron - leave blank if only cron): " RUN_ON_BOOT;\
		if ! [ -z "$${RUN_ON_BOOT}" ]; then\
			echo "Writing RUN_ON_BOOT...";\
			sed -i '/RUN_ON_BOOT=/d' $${ENV_FILE};\
			echo "RUN_ON_BOOT=$${RUN_ON_BOOT}" >> "$${ENV_FILE}";\
		fi;\
		read -p "PUID (most likely 'id -u' for you - leave blank if n/a): " PUID;\
		if ! [ -z "$${PUID}" ]; then\
			echo "Writing PUID...";\
			sed -i '/PUID=/d' $${ENV_FILE};\
			echo "PUID=$${PUID}" >> "$${ENV_FILE}";\
		fi;\
		read -p "PGID (most likely 'id -g' for you - leave blank if n/a): " PGID;\
		if ! [ -z "$${PGID}" ]; then\
			echo "Writing PGID...";\
			sed -i '/PGID=/d' $${ENV_FILE};\
			echo "PGID=$${PGID}" >> "$${ENV_FILE}";\
		fi;\
	fi;
