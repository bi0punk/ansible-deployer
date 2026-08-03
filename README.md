# Deployer

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Sistema de despliegue automatizado con Ansible. Soporta aplicaciones Python, shell scripts, Docker Compose y Git repos en servidores remotos.

## Tabla de Contenidos

- [Características](#características)
- [Stack](#stack)
- [Arquitectura](#arquitectura)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Playbooks](#playbooks)
- [Roles](#roles)
- [Inventarios](#inventarios)
- [Ejemplos](#ejemplos)
- [Licencia](#licencia)

## Características

- Despliegue de aplicaciones Python, shell scripts y entrypoints
- Gestión de contenedores Docker Compose
- Health checks post-deploy
- Soporte multi-entorno (dev, staging, prod)
- Ejecución remota con systemd para persistencia
- Rollback y cleanup

## Stack

- Ansible
- YAML
- Bash
- Docker / Docker Compose

## Arquitectura

```
deployer/
├── ansible-deployer/
│   ├── playbooks/           # Playbooks principales
│   │   ├── site.yml         # Orquestador principal
│   │   ├── deploy.yml       # Deploy Docker Compose
│   │   ├── run_python.yml   # Ejecutar app Python
│   │   ├── run_shell.yml    # Ejecutar script shell
│   │   ├── run_entrypoint.yml
│   │   ├── run_git_repo_auto.yml
│   │   ├── install_docker.yml
│   │   ├── stop.yml
│   │   ├── status.yml
│   │   └── cleanup.yml
│   ├── roles/
│   │   ├── docker_deploy/   # Deploy de contenedores Docker
│   │   ├── deploy_app/      # Deploy de aplicaciones
│   │   └── remote_executor/ # Ejecución remota (Python, shell, entrypoint, git)
│   ├── inventories/         # Inventarios multi-entorno
│   │   ├── prod/
│   │   ├── staging/
│   │   └── dev/
│   ├── composes/            # Templates Docker Compose
│   ├── examples/            # Apps de ejemplo
│   └── ansible.cfg
└── LICENSE
```

## Requisitos

- Ansible 2.9+
- Python 3.8+ en nodo de control
- Acceso SSH a servidores remotos
- Docker/Docker Compose en nodos gestionados (para deploy de contenedores)

## Instalación

```bash
git clone https://github.com/bi0punk/deployer.git
cd deployer/ansible-deployer
ansible-galaxy collection install -r collections/requirements.yml
```

## Uso

```bash
# Desplegar con Docker Compose
ansible-playbook -i inventories/prod/hosts.yml playbooks/deploy.yml

# Ejecutar aplicación Python remota
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_python.yml

# Ejecutar script shell remoto
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_shell.yml

# Ver estado de servicios
ansible-playbook -i inventories/prod/hosts.yml playbooks/status.yml

# Detener servicios
ansible-playbook -i inventories/prod/hosts.yml playbooks/stop.yml

# Instalar Docker en nodos
ansible-playbook -i inventories/prod/hosts.yml playbooks/install_docker.yml
```

## Playbooks

| Playbook | Descripción |
|----------|-------------|
| `site.yml` | Orquestador principal |
| `deploy.yml` | Deploy de stacks Docker Compose |
| `run_python.yml` | Sincroniza y ejecuta app Python como systemd |
| `run_shell.yml` | Sincroniza y ejecuta script shell como systemd |
| `run_entrypoint.yml` | Ejecuta entrypoint personalizado |
| `run_git_repo_auto.yml` | Clona repo Git y ejecuta |
| `install_docker.yml` | Instala Docker en nodos remotos |
| `stop.yml` | Detiene servicios gestionados |
| `status.yml` | Muestra estado de servicios |
| `cleanup.yml` | Limpia artefactos de deploy |

## Roles

### docker_deploy
Gestiona el ciclo de vida de stacks Docker Compose: preparación de directorios, sincronización de archivos, pull de imágenes, compose up y health checks.

### deploy_app
Prepara directorios, despliega templates systemd (`.env`, `.service`) y recarga el daemon en nodos remotos.

### remote_executor
Ejecución remota genérica con soporte para:
- Apps Python (`run_python.yml`)
- Shell scripts (`run_shell.yml`)
- Entrypoints personalizados (`run_entrypoint.yml`)
- Clonado de repos Git (`clone_repo.yml`)

## Inventarios

```
inventories/
├── prod/        # Producción
├── staging/     # Pre-producción
└── dev/         # Desarrollo
```

Cada entorno define sus propios hosts y group_vars.

## Ejemplos

El directorio `examples/` contiene:
- `python/` — App Python mínima
- `shell/` — Script shell de ejemplo
- `compose/` — Docker Compose de ejemplo
- `entrypoint/` — Entrypoint personalizado
- `gitlab-auto.example.yml` — Configuración para GitLab CI

## Licencia

MIT
