SHELL := /bin/bash
INVENTORY ?= inventories/prod/hosts.yml
EXTRA ?=

.PHONY: install ping shell python entrypoint compose git-auto generic lint

install:
	ansible-galaxy collection install -r collections/requirements.yml

ping:
	ansible -i $(INVENTORY) all -m ping

shell:
	ansible-playbook -i $(INVENTORY) playbooks/run_shell.yml $(EXTRA)

python:
	ansible-playbook -i $(INVENTORY) playbooks/run_python.yml $(EXTRA)

entrypoint:
	ansible-playbook -i $(INVENTORY) playbooks/run_entrypoint.yml $(EXTRA)

compose:
	ansible-playbook -i $(INVENTORY) playbooks/run_compose.yml $(EXTRA)

git-auto:
	ansible-playbook -i $(INVENTORY) playbooks/run_git_repo_auto.yml $(EXTRA)

generic:
	ansible-playbook -i $(INVENTORY) playbooks/site.yml $(EXTRA)

lint:
	@echo "Instala ansible-lint localmente si quieres validar estilo y buenas prácticas"
