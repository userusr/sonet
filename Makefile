-include .env

# Project instance name
PROJECT ?= sonet
# Project version
VERSION ?= 0.0.1
# Ansible inventory file
INVENTORY ?= ./configs/sonet_local/inventory.yml
# Ansible playbook
PLAYBOOK ?= ./configs/sonet_local/playbook.yml
#
LOCAL_DOCKER_REGISTRY_ADDR ?= registry.sonet.local
#
LOCAL_DOCKER_REGISTRY_PORT ?= 5000
#
LOCAL_DOCKER_REGISTRY_BIND_IP ?= 127.0.0.1
# Ask become password (1 - ask)
ANSIBLE_ASK_BECOME_PASS ?= 0
#
ANSIBLE_VAULT_PASSWORD ?= sonet
export ANSIBLE_VAULT_PASSWORD
#
ANSIBLE_VAULT_CLIENT_SCRIPT ?= ./tools/vault-env-client.py
#
ANSIBLE_PYTHON_INTERPRETE ?= python3
#
ANSIBLE_PLAYBOOK ?= ansible-playbook
#
VENV_DIR ?= venv
#
LOCAL_PLAYBOOK_PATH=$(shell dirname `realpath $(PLAYBOOK)`)
# Project name for composer by default
COMPOSER_PROJECT=$(PROJECT)
#
REGISTRY_CONTAINER_NAME ?= $(PROJECT)-registry
#
REGISTRY_DATA_DIR ?= $(shell pwd)/registry

ifeq ($(wildcard ${VENV_DIR}),)
	VENV_BIN=
else
	VENV_BIN=./${VENV_DIR}/bin/
endif

ifeq ($(ANSIBLE_ASK_BECOME_PASS),1)
	ANSIBLE_ASK_BECOME_PASS_PARAM=--ask-become-pass
else
	ANSIBLE_ASK_BECOME_PASS_PARAM=
endif

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

ANSIBLE_VARS := "project": "$(PROJECT)", \
		"local_playbook_path": "$(LOCAL_PLAYBOOK_PATH)", \
		"local_docker_registry_addr": "$(LOCAL_DOCKER_REGISTRY_ADDR)", \
		"local_docker_registry_port": "$(LOCAL_DOCKER_REGISTRY_PORT)"

_build:
	${ANSIBLE_PLAYBOOK} $(ANSIBLE_DEBUG) \
		$(PLAYBOOK) \
		--vault-password-file $(ANSIBLE_VAULT_CLIENT_SCRIPT) \
		--inventory $(INVENTORY) \
		$(ANSIBLE_ASK_BECOME_PASS_PARAM) \
		--tags '$(TAGS)' \
		--skip-tags '$(SKIP_TAGS)' \
		--extra-vars '{ $(ANSIBLE_ADD_VARS), $(ANSIBLE_VARS) }'

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

pip-requirements: ## compile requirements with pip-compile
	${VENV_BIN}pip-compile requirements.in > requirements.txt
	${VENV_BIN}pip-compile requirements_dev.in > requirements_dev.txt

venv:  ## make python virtualenv
	python3 -m venv ${VENV_DIR} && \
	./${VENV_DIR}/bin/pip install -U pip pip-tools && \
	./${VENV_DIR}/bin/pip install -r requirements.txt

clean: ## remove all project containers
	docker ps -a \
	| grep $(PROJECT) \
	| awk '{print $$1}' \
	| xargs --no-run-if-empty docker rm --force --volumes

clean-images: ## delete all project images
	docker images \
	| grep $(PROJECT) \
	| awk '{print $$3}' \
	| xargs --no-run-if-empty docker rmi --force

lint: ## lint ansible and yaml files
	yamllint .
	${ANSIBLE_PLAYBOOK} $(PLAYBOOK) --inventory $(INVENTORY) --syntax-check
	ansible-lint $(PLAYBOOK)

docs: ## generate Sphinx HTML documentation
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	${VENV_BIN}watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

registry-start: ## start local docker registry
	[ ! "$$(docker ps -q -f name=${REGISTRY_CONTAINER_NAME})" ] && \
		docker run --detach --rm \
			--publish $(LOCAL_DOCKER_REGISTRY_BIND_IP):$(LOCAL_DOCKER_REGISTRY_PORT):5000 \
			--name ${REGISTRY_CONTAINER_NAME} \
			--volume "$(REGISTRY_DATA_DIR)":/var/lib/registry \
			registry:2

registry-stop: ## stop local docker registry
	docker rm --force ${REGISTRY_CONTAINER_NAME}

init: ANSIBLE_ADD_VARS="dummy": true
init: TAGS=init
init: SKIP_TAGS=skip-init
init: | $(PROJECT) _build  ## create folders and generate configs

build: ANSIBLE_ADD_VARS="dummy": true
build: TAGS=build
build: SKIP_TAGS=skip-build
build: | $(PROJECT) _build  ## build all docker images

push: ANSIBLE_ADD_VARS="dummy": true
push: TAGS=push
push: SKIP_TAGS=skip-push
push: | $(PROJECT) _build  ## push docker images to local registry

run: ANSIBLE_ADD_VARS="dummy": true
run: TAGS=run
run: SKIP_TAGS=skip-run
run: | $(PROJECT) _build  ## push docker images to local registry

.PHONY: venv docs $(PROJECT)

.DEFAULT_GOAL := help
