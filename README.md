# ansible-remote-runner

Proyecto Ansible unificado para ejecución remota de scripts y despliegue de stacks Docker Compose en servidores Linux.

## Capacidades

- **Ejecución multi-modo**: shell, python, entrypoint, git-auto
- **Docker Compose**: despliegue interactivo con health checks, rsync y backups
- **Auto-detección**: detecta automáticamente cómo ejecutar un proyecto clonado
- **systemd**: instala servicios persistentes para shell/python/entrypoint
- **Payload upload**: copia archivos locales al servidor remoto
- **Git integration**: clona/actualiza repositorios con soporte SSH
- **Instalación Docker**: playbook para instalar Docker Engine en servidores

## Estructura

```
ansible-remote-runner/
├── ansible.cfg
├── Makefile
├── collections/
│   └── requirements.yml
├── composes/                          # Proyectos Docker Compose
│   └── examples/
├── examples/                          # Ejemplos de scripts
│   ├── shell/  python/  entrypoint/  compose/
│   └── gitlab-auto.example.yml
├── group_vars/                        # Variables globales
│   └── all.yml
├── inventories/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── payload/                           # Directorio para upload
├── playbooks/
│   ├── run_shell.yml                  # Ejecución shell
│   ├── run_python.yml                 # Ejecución Python
│   ├── run_entrypoint.yml             # Ejecución entrypoint
│   ├── run_git_repo_auto.yml          # Git + auto-detección
│   ├── site.yml                       # Despliegue genérico
│   ├── deploy.yml                     # Docker Compose interactivo
│   ├── status.yml                     # Estado de proyectos Docker
│   ├── stop.yml                       # Detener proyectos Docker
│   ├── cleanup.yml                    # Limpieza Docker
│   ├── install_docker.yml             # Instalar Docker
│   ├── detect_project.yml             # Detectar tipo de proyecto
│   └── detect_and_deploy.yml          # Clonar + detectar + desplegar
├── roles/
│   ├── remote_executor/               # Ejecución multi-modo
│   ├── docker_deploy/                 # Docker Compose avanzado
│   └── deploy_app/                    # Deploy Python opinionado
```

## Uso rápido

```bash
# Instalar colecciones
make install

# Verificar conectividad
make ping

# Ejecutar script shell
make shell

# Clonar repo y auto-detectar modo
make git-auto

# Desplegar Docker Compose (selección interactiva)
make deploy PROJECT=mi-app

# Ver estado de proyectos Docker
make status

# Instalar Docker en servidores
make install-docker
```

## Entornos

| Entorno  | Inventario                     | Uso                          |
|----------|--------------------------------|------------------------------|
| dev      | inventories/dev/hosts.yml      | Desarrollo                   |
| staging  | inventories/staging/hosts.yml  | Pre-producción               |
| prod     | inventories/prod/hosts.yml     | Producción                   |

```bash
make shell INVENTORY=inventories/staging/hosts.yml
```

## Roles

| Rol              | Descripción                                                   |
|------------------|---------------------------------------------------------------|
| remote_executor  | Ejecuta scripts shell/python/entrypoint, clona repos, systemd |
| docker_deploy    | Despliega Docker Compose con health check, rsync, backups     |
| deploy_app       | Despliegue opinionado de apps Python con venv y hardening     |

## Requisitos

- **Control node**: Linux, ansible-core, Python 3.8+, SSH
- **Target**: Linux, Python 3, sudo, git, Docker (para compose)
