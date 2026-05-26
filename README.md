# 🐳 Ansible Docker Deployer

Proyecto Ansible para despliegue interactivo de proyectos Docker Compose en máquinas Linux remotas.

## 📁 Estructura del proyecto

```
ansible-docker-deployer/
├── ansible.cfg                   # Configuración global de Ansible
├── inventory/
│   ├── hosts.ini                 # Inventario de servidores
│   └── group_vars/
│       └── all.yml               # Variables compartidas
├── composes/                     # ← Aquí van tus proyectos Docker
│   ├── mi-app/
│   │   ├── docker-compose.yml
│   │   └── .env                  # (opcional)
│   ├── otro-proyecto/
│   │   └── docker-compose.yml
│   └── examples/                 # Ejemplos incluidos
├── playbooks/
│   ├── deploy.yml                # ← Playbook principal (selección interactiva)
│   ├── status.yml                # Ver estado de todos los proyectos
│   ├── stop.yml                  # Detener un proyecto
│   └── cleanup.yml               # Limpiar recursos Docker
├── roles/
│   └── docker_deploy/            # Rol principal de despliegue
│       ├── tasks/
│       ├── defaults/
│       └── templates/
└── library/
    └── docker_compose_info.py    # Módulo custom de información
```

## 🚀 Uso rápido

### 1. Configurar inventario
Edita `inventory/hosts.ini` con tus servidores.

### 2. Añadir tus proyectos Docker
Coloca tus `docker-compose.yml` en `composes/`:
```bash
# Opción A: archivo solo
composes/mi-app.yml

# Opción B: directorio con compose + .env + configs
composes/mi-app/
├── docker-compose.yml
├── .env
└── nginx.conf
```

### 3. Desplegar (selección interactiva)
```bash
ansible-playbook playbooks/deploy.yml -i inventory/hosts.ini
```

### 4. Ver estado de los proyectos
```bash
ansible-playbook playbooks/status.yml -i inventory/hosts.ini
```

### 5. Detener un proyecto
```bash
ansible-playbook playbooks/stop.yml -i inventory/hosts.ini
```

## ⚙️ Variables configurables

| Variable | Default | Descripción |
|---|---|---|
| `docker_deploy_base_path` | `/opt/docker-projects` | Ruta en el servidor remoto |
| `docker_compose_bin` | `docker compose` | Comando de docker compose |
| `docker_pull_always` | `true` | Hacer pull antes de levantar |
| `backup_before_deploy` | `false` | Backup de volúmenes antes de desplegar |
| `deploy_env` | `production` | Entorno de despliegue |

## 📋 Requisitos

### En el controlador (tu máquina)
- Ansible >= 2.12
- Python 3.8+

### En los servidores remotos
- Docker Engine >= 20.10
- Docker Compose plugin (v2) o docker-compose (v1)
- Python 3.x (para módulos Ansible)
- Usuario con permisos de Docker o sudo

## 🔐 Variables de entorno sensibles

Usa `ansible-vault` para proteger credenciales:
```bash
ansible-vault encrypt_string 'mi_password_secreto' --name 'db_password'
```

Luego en el playbook:
```bash
ansible-playbook playbooks/deploy.yml -i inventory/hosts.ini --ask-vault-pass
```
