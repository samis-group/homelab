THIS_FILE := $(lastword $(MAKEFILE_LIST))
.PHONY: help build up start down destroy stop restart logs logs-api ps login-timescale login-api db-shell
help:
        make -pRrq  -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
build:
        VAR=$(find . -name "*$(ARGS)*")
        docker-compose -f ${VAR} build $(c)
up:
        docker-compose -f $(ARGS) up -d $(c)
start:
        docker-compose -f $(ARGS) start $(c)
down:
        docker-compose -f $(ARGS) down $(c)
destroy:
        docker-compose -f $(ARGS) down -v $(c)
stop:
        docker-compose -f $(ARGS) stop $(c)
restart:
        docker-compose -f $(ARGS) stop $(c)
        docker-compose -f $(ARGS) up -d $(c)
logs:
        docker-compose -f $(ARGS) logs --tail=100 -f $(c)
logs-api:
        docker-compose -f $(ARGS) logs --tail=100 -f api
ps:
        docker-compose -f $(ARGS) ps
login-timescale:
        docker-compose -f $(ARGS) exec timescale /bin/bash
login-api:
        docker-compose -f $(ARGS) exec api /bin/bash
db-shell:
        docker-compose -f $(ARGS) exec timescale psql -Upostgres
