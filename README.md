# ansible-remote-runner

Proyecto Ansible profesional para ejecutar en un servidor remoto cualquiera de estos modos:

1. Script `.sh`
2. Script `.py`
3. `entrypoint.sh`
4. `docker compose`
5. Repositorio Git/GitLab con autodetección de ejecución

El objetivo es darte una base limpia, extensible y apta para entornos reales Linux.

---

## 1) Qué resuelve

Este proyecto te permite:

- ejecutar tareas one-shot remotas
- desplegar servicios persistentes con `systemd`
- subir un payload local al servidor remoto
- clonar o actualizar un repositorio Git/GitLab en el servidor remoto
- detectar automáticamente si un repo se corre con Compose, entrypoint, Python o shell
- separar inventario, variables, playbooks y rol reutilizable

---

## 2) Estructura

```text
ansible-remote-runner/
├── ansible.cfg
├── collections/
│   └── requirements.yml
├── inventories/
│   ├── dev/
│   │   ├── group_vars/
│   │   │   └── all.yml
│   │   └── hosts.yml
│   └── prod/
│       ├── group_vars/
│       │   └── all.yml
│       └── hosts.yml
├── playbooks/
│   ├── run_compose.yml
│   ├── run_entrypoint.yml
│   ├── run_git_repo_auto.yml
│   ├── run_python.yml
│   ├── run_shell.yml
│   └── site.yml
├── roles/
│   └── remote_executor/
│       ├── defaults/
│       │   └── main.yml
│       ├── handlers/
│       │   └── main.yml
│       ├── tasks/
│       │   ├── clone_repo.yml
│       │   ├── detect_runner.yml
│       │   ├── main.yml
│       │   ├── prepare.yml
│       │   ├── run_compose.yml
│       │   ├── run_entrypoint.yml
│       │   ├── run_python.yml
│       │   ├── run_shell.yml
│       │   └── upload.yml
│       └── templates/
│           ├── systemd-entrypoint.service.j2
│           ├── systemd-python.service.j2
│           └── systemd-script.service.j2
├── examples/
│   ├── compose/
│   │   └── docker-compose.yml
│   ├── entrypoint/
│   │   └── entrypoint.sh
│   ├── gitlab-auto.example.yml
│   ├── python/
│   │   └── app.py
│   └── shell/
│       └── run.sh
├── payload/
│   └── README.md
└── Makefile
```

---

## 3) Requisitos

### Control node

- Linux
- `ansible-core` o `ansible`
- acceso SSH al servidor remoto
- clave SSH o autenticación válida

### Target remoto

- Linux
- Python 3 instalado
- `sudo` si usarás `become`
- `git` si usarás repositorios remotos
- Docker + plugin `docker compose` si usarás el modo compose

Instalación de la colección necesaria para Compose:

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

---

## 4) Ajuste rápido del inventario

Edita:

- `inventories/prod/hosts.yml`
- `inventories/prod/group_vars/all.yml`

Ejemplo mínimo:

```yaml
all:
  children:
    app_servers:
      hosts:
        prod-app-01:
          ansible_host: 192.168.1.100
          ansible_user: debian
          ansible_port: 22
```

Prueba conectividad:

```bash
ansible -i inventories/prod/hosts.yml all -m ping
```

---

## 5) Variables principales

Archivo: `inventories/prod/group_vars/all.yml`

### Variables base

- `app_name`: nombre lógico del despliegue
- `remote_app_dir`: directorio base remoto
- `runner_mode`: `shell | python | entrypoint | compose | auto`
- `runner_as_service`: `true` para dejarlo como servicio systemd
- `upload_payload`: `true` para copiar `./payload` al remoto
- `runner_env`: variables de entorno
- `runner_workdir`: directorio de trabajo remoto

### Para repos Git/GitLab

- `git_repo_enabled`: activa clonado/actualización remota
- `git_repo_url`: URL SSH o HTTPS del repo
- `git_repo_version`: branch, tag o commit
- `git_repo_dest`: ruta donde se clona el repo
- `git_repo_key_file`: clave SSH opcional si el repo es privado
- `git_repo_accept_hostkey`: aceptar host key de GitLab

### Para cada modo manual

- `shell_script_path`, `shell_script_args`
- `python_bin`, `python_script_path`, `python_script_args`
- `entrypoint_path`, `entrypoint_args`
- `compose_project_name`, `compose_files`, `compose_state`

---

## 6) Cómo funciona la autodetección

Cuando pones:

```yaml
runner_mode: auto
```

el rol revisa el directorio efectivo del proyecto y aplica esta prioridad:

1. `docker-compose.yml`, `docker-compose.yaml`, `compose.yml`, `compose.yaml`
2. `entrypoint.sh`, `docker-entrypoint.sh`, `start.sh`
3. `app.py`, `main.py`, `server.py`, `run.py`, `manage.py`
4. `run.sh`, `start.sh`, `deploy.sh`, `script.sh`
5. fallback: primer `*.sh` en la raíz del repo

Si no encuentra una convención conocida, falla con mensaje claro para que fuerces el `runner_mode` manualmente.

---

## 7) Uso por escenario

### A. Ejecutar un `.sh`

```yaml
runner_mode: shell
runner_as_service: false
shell_script_path: /opt/demo-app/run.sh
shell_script_args: ["--modo", "full"]
```

```bash
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_shell.yml
```

---

### B. Ejecutar un `.py`

```yaml
runner_mode: python
runner_as_service: false
python_bin: /usr/bin/python3
python_script_path: /opt/demo-app/app.py
python_script_args: ["--input", "/data/file.csv"]
```

```bash
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_python.yml
```

---

### C. Ejecutar un entrypoint como servicio

```yaml
runner_mode: entrypoint
runner_as_service: true
entrypoint_path: /opt/demo-app/entrypoint.sh
entrypoint_args: []
systemd_unit_name: demo-app.service
```

```bash
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_entrypoint.yml
```

---

### D. Levantar Docker Compose

```yaml
runner_mode: compose
upload_payload: true
compose_project_name: demo-app
compose_files:
  - /opt/demo-app/docker-compose.yml
```

```bash
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_compose.yml
```

---

### E. Clonar repo GitLab y autodetectar cómo correrlo

Caso ideal para repos con convención razonable.

```yaml
app_name: mi-app-gitlab
remote_app_dir: "/opt/{{ app_name }}"

git_repo_enabled: true
git_repo_url: "git@gitlab.com:mi-grupo/mi-proyecto.git"
git_repo_version: main
git_repo_dest: "{{ remote_app_dir }}/src"
git_repo_key_file: "/root/.ssh/id_ed25519"
git_repo_accept_hostkey: true

runner_mode: auto
runner_as_service: false
runner_workdir: "{{ remote_app_dir }}"
```

Ejecución:

```bash
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_git_repo_auto.yml
```

O con `make`:

```bash
make git-auto
```

---

## 8) Repos privados GitLab

Si el repo es privado, normalmente lo más limpio es:

1. cargar una clave SSH en el servidor remoto
2. dar acceso de lectura al proyecto o al grupo
3. definir `git_repo_key_file`
4. usar URL SSH del repo

Ejemplo:

```yaml
git_repo_url: "git@gitlab.com:empresa/plataforma-api.git"
git_repo_key_file: "/root/.ssh/id_ed25519_gitlab"
```

---

## 9) Ejemplos rápidos de comando

```bash
cd ansible-remote-runner
ansible-galaxy collection install -r collections/requirements.yml
ansible -i inventories/prod/hosts.yml all -m ping
ansible-playbook -i inventories/prod/hosts.yml playbooks/run_git_repo_auto.yml
```

---

## 10) Qué hace bien esta base

- no rompe el flujo actual por payload local
- suma un flujo Git/GitLab opcional
- permite override manual si la autodetección no aplica
- deja el proyecto listo para evolucionar a releases, rollback y healthchecks

---

## 11) Siguiente mejora recomendable

La evolución natural sería agregar:

1. `preflight.yml` para validar `git`, `docker`, `python`, espacio y permisos
2. despliegue por `releases/` + symlink `current`
3. rollback rápido
4. `vault` para secretos
5. `healthcheck` post-deploy
6. soporte `requirements.txt` / `pyproject.toml` con creación de venv

