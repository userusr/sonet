.PHONY: venv docs

.DEFAULT_GOAL := help

-include .env

# Project instance name
PROJECT ?= sonet
# Project name for composer by default
COMPOSER_PROJECT=$(PROJECT)
# Ansible inventory file
INVENTORY ?= inventories/sonet.local/inventory
# Ansible playbook
PLAYBOOK ?= inventories/sonet.local/playbook.yml
#
LOCAL_PLAYBOOK_PATH ?= $(shell dirname `realpath $(PLAYBOOK)`)
#
ANSIBLE_ASK_BECOME_PASS ?= 0
#
ANSIBLE_PYTHON_INTERPRETE ?= python3
#
ANSIBLE_PLAYBOOK ?= ansible-playbook
#
VAULT_PASSWORD_FILE ?= $(shell realpath ~/.ssh/id_rsa)

ifeq ($(ANSIBLE_ASK_BECOME_PASS),1)
	ANSIBLE_ASK_BECOME_PASS=--ask-become-pass
else
	ANSIBLE_ASK_BECOME_PASS=
endif

ifeq ($(VAULT_PASSWORD_FILE),)
	ANSIBLE_VAULT_PASSWORD_FILE=
else
	ANSIBLE_VAULT_PASSWORD_FILE=--vault-password-file $(VAULT_PASSWORD_FILE)
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
		"git_url": "$(GIT_URL)"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

venv:  ## make python virtualenv
	python -m venv ${VENV_DIR} && \
	./${VENV_DIR}/bin/pip install -U pip
	./${VENV_DIR}/bin/pip install -r requirements.txt

$(PROJECT):

clean-all: clean clean-images

clean:
	docker ps -a \
	| grep $(PROJECT) \
	| awk '{print $$1}' \
	| xargs --no-run-if-empty docker rm --force --volumes

clean-images:
	docker images \
	| grep $(PROJECT) \
	| awk '{print $$3}' \
	| xargs --no-run-if-empty docker rmi --force

lint:
	yamllint .
	${ANSIBLE_PLAYBOOK} $(PLAYBOOK) --inventory $(INVENTORY) --syntax-check
	ansible-lint $(PLAYBOOK)

_build:
	${ANSIBLE_PLAYBOOK} $(ANSIBLE_DEBUG) \
		$(PLAYBOOK) \
		--inventory $(INVENTORY) \
		$(ANSIBLE_VAULT_PASSWORD_FILE) \
		$(ANSIBLE_ASK_BECOME_PASS) \
		--tags '$(TAGS)' \
		--extra-vars '{ $(ANSIBLE_ADD_VARS), $(ANSIBLE_VARS) }'

docs: ## generate Sphinx HTML documentation
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	${VENV_BIN}watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

registry-start:
	docker run -d --rm \
		-e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
		-p 5000:5000 \
		--name registry \
		-e "REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data" \
		-v "$(shell pwd)/registry":/data \
		registry:2

registry-stop:
	docker rm -f registry

init: ANSIBLE_ADD_VARS="dummy": true
init: TAGS=init, generate
init: | $(PROJECT) _build  ## build all docker images

build: ANSIBLE_ADD_VARS="dummy": true
build: TAGS=build
build: | $(PROJECT) _build  ## build all docker images

push: ANSIBLE_ADD_VARS="dummy": true
push: TAGS=push
push: | $(PROJECT) _build  ## pull docker images
