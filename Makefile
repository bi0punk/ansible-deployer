SHELL := /bin/bash
INVENTORY ?= inventories/prod/hosts.yml
EXTRA ?=
EXTRA_VARS ?=

ifdef PROJECT
  EXTRA_VARS += selected_project=$(PROJECT)
endif

.PHONY: help install ping shell python entrypoint git-auto generic \
        deploy status stop cleanup cleanup-all install-docker check lint list-projects

help:
	@grep -E '^## [a-z]' Makefile | sed 's/^## /  make /'

install:
	ansible-galaxy collection install -r collections/requirements.yml

ping:
	ansible -i $(INVENTORY) all -m ping

## shell: Ejecutar script shell remoto
shell:
	ansible-playbook -i $(INVENTORY) playbooks/run_shell.yml $(EXTRA)

## python: Ejecutar script Python remoto
python:
	ansible-playbook -i $(INVENTORY) playbooks/run_python.yml $(EXTRA)

## entrypoint: Ejecutar entrypoint remoto
entrypoint:
	ansible-playbook -i $(INVENTORY) playbooks/run_entrypoint.yml $(EXTRA)

## git-auto: Clonar repo y autodetectar modo de ejecucion
git-auto:
	ansible-playbook -i $(INVENTORY) playbooks/run_git_repo_auto.yml $(EXTRA)

## generic: Despliegue generico segun runner_mode
generic:
	ansible-playbook -i $(INVENTORY) playbooks/site.yml $(EXTRA)

## deploy: Desplegar Docker Compose (seleccion interactiva)
deploy:
	ansible-playbook -i $(INVENTORY) playbooks/deploy.yml $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)",)

## status: Ver estado de proyectos Docker desplegados
status:
	ansible-playbook -i $(INVENTORY) playbooks/status.yml

## stop: Detener proyecto Docker
stop:
	ansible-playbook -i $(INVENTORY) playbooks/stop.yml $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)",)

## cleanup: Limpiar recursos Docker no utilizados
cleanup:
	ansible-playbook -i $(INVENTORY) playbooks/cleanup.yml

## cleanup-all: Limpiar TODO (imagenes, volumenes, redes)
cleanup-all:
	ansible-playbook -i $(INVENTORY) playbooks/cleanup.yml -e "prune_all=true"

## install-docker: Instalar Docker en servidores remotos
install-docker:
	ansible-playbook -i $(INVENTORY) playbooks/install_docker.yml

## check: Verificar conectividad con todos los servidores
check:
	ansible all -i $(INVENTORY) -m ping

## lint: Validar sintaxis de todos los playbooks
lint:
	@for pb in playbooks/*.yml; do \
	  echo "  -> $$pb"; \
	  ansible-playbook --syntax-check -i $(INVENTORY) $$pb 2>/dev/null && echo "    OK" || echo "    ERROR: $$pb"; \
	done

## list-projects: Listar proyectos Docker disponibles en ./composes
list-projects:
	@find composes/ -name "docker-compose.yml" -o -name "docker-compose.yaml" \
	  -o -name "compose.yml" | sort | sed 's|^|  * |'
