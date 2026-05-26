# =============================================================
#  Makefile — Ansible Docker Deployer
#  Uso: make <target> [HOST=mi-servidor] [PROJECT=mi-app]
# =============================================================

INVENTORY   ?= inventory/hosts.ini
EXTRA_VARS  ?=

ifdef PROJECT
  EXTRA_VARS += selected_project=$(PROJECT)
endif

.PHONY: help deploy status stop cleanup install-docker check lint

## help: Mostrar esta ayuda
help:
	@echo ""
	@echo "  🐳 Ansible Docker Deployer"
	@echo ""
	@echo "  Targets disponibles:"
	@grep -E '^## [a-z]' Makefile | sed 's/^## /  make /'
	@echo ""
	@echo "  Variables:"
	@echo "    INVENTORY=path/to/hosts.ini  (default: inventory/hosts.ini)"
	@echo "    PROJECT=nombre-del-proyecto   (omite selección interactiva)"
	@echo ""

## deploy: Desplegar un proyecto (selección interactiva si no se especifica PROJECT)
deploy:
	ansible-playbook playbooks/deploy.yml -i $(INVENTORY) \
	  $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)",)

## status: Ver estado de todos los proyectos desplegados
status:
	ansible-playbook playbooks/status.yml -i $(INVENTORY)

## stop: Detener un proyecto Docker (selección interactiva)
stop:
	ansible-playbook playbooks/stop.yml -i $(INVENTORY) \
	  $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)",)

## cleanup: Limpiar recursos Docker no utilizados
cleanup:
	ansible-playbook playbooks/cleanup.yml -i $(INVENTORY)

## cleanup-all: Limpiar TODO (imágenes, volúmenes, redes)
cleanup-all:
	ansible-playbook playbooks/cleanup.yml -i $(INVENTORY) -e "prune_all=true"

## install-docker: Instalar Docker en los servidores
install-docker:
	ansible-playbook playbooks/install_docker.yml -i $(INVENTORY)

## check: Verificar conectividad con todos los servidores
check:
	ansible all -i $(INVENTORY) -m ping

## lint: Validar sintaxis de todos los playbooks
lint:
	@echo "Validando playbooks..."
	@for pb in playbooks/*.yml; do \
	  echo "  → $$pb"; \
	  ansible-playbook --syntax-check -i $(INVENTORY) $$pb 2>/dev/null && echo "    ✅ OK" || echo "    ❌ ERROR"; \
	done

## list-projects: Listar proyectos disponibles en ./composes
list-projects:
	@echo ""
	@echo "Proyectos disponibles en ./composes:"
	@find composes/ -name "docker-compose.yml" -o -name "docker-compose.yaml" \
	  -o -name "compose.yml" | sort | sed 's|^|  📦 |'
	@echo ""
