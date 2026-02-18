# Ansible: Deploy de proyecto (GitHub) a servidor remoto (Debian/Ubuntu)

Este proyecto despliega un repositorio (público o privado) desde GitHub (o cualquier URL Git),
crea un usuario de despliegue, prepara un *virtualenv* (Python), instala dependencias,
renderiza un archivo `.env` en el servidor y levanta un servicio systemd.

## Requisitos (en tu PC)
- `ansible-core` >= 2.15 (ideal 2.16+)
- Acceso SSH al servidor (usuario con sudo)
- Python 3 en el servidor (normalmente ya está)

Instalar ansible (Debian/Ubuntu):
```bash
sudo apt-get update
sudo apt-get install -y ansible
```

## 1) Configura inventario
Edita:
- `inventories/prod/hosts.ini`
- `inventories/prod/group_vars/app.yml`

Ejemplo rápido (solo para probar):
```bash
sed -i 's/1.2.3.4/TU_IP/g' inventories/prod/hosts.ini
```

## 2) Si tu repo es privado
La forma limpia es usar **Deploy Key** (recomendado):
1. En tu PC crea una key:
   ```bash
   ssh-keygen -t ed25519 -C "ansible-deploy" -f ./deploy_key -N ""
   ```
2. Agrega `deploy_key.pub` como **Deploy key** en GitHub (solo lectura).
3. Copia `deploy_key` al servidor *o* (mejor) usa `ansible-vault` (ver abajo).

Este proyecto soporta clave en el servidor vía variable `git_ssh_key_path` (ruta remota).

## 3) Ejecuta el despliegue
```bash
ansible-playbook -i inventories/prod/hosts.ini site.yml
```

## Variables principales
En `inventories/prod/group_vars/app.yml`:
- `repo_url`: URL Git (https o ssh)
- `git_version`: branch/tag/commit (por defecto `main`)
- `app_name`: nombre lógico del servicio
- `app_user`: usuario Linux del servicio (por defecto `deploy`)
- `app_dir`: directorio donde clonar (por defecto `/opt/apps/<app_name>`)
- `venv_dir`: virtualenv (por defecto `/opt/venvs/<app_name>`)
- `app_workdir`: cwd del servicio (por defecto `app_dir`)
- `exec_start`: comando ExecStart (ver ejemplos)
- `env_vars`: dict con variables de entorno para el `.env`

## Ejemplos de ExecStart
### A) Script Python dentro del repo (simple)
Si tu repo tiene `main.py` en la raíz:
```yaml
exec_start: "{{ venv_dir }}/bin/python {{ app_dir }}/main.py"
```

### B) App ASGI/WSGI (uvicorn/gunicorn)
Si tienes `requirements.txt` y `app:app`:
```yaml
exec_start: "{{ venv_dir }}/bin/uvicorn app:app --host 0.0.0.0 --port 8000"
```

## Re-deploy / update
Ansible hará `git pull` (idempotente) y reiniciará el servicio si hubo cambios en el código o en el `.env`.

## Logs
```bash
sudo journalctl -u <app_name> -f
```

## Vault (opcional, recomendado)
Para secretos (tokens, keys, passwords) usa `ansible-vault`.
Ejemplo:
```bash
ansible-vault create inventories/prod/group_vars/vault.yml
```
Luego en `inventories/prod/group_vars/app.yml` referencia variables desde `vault.yml`.

Ejecutar con vault:
```bash
ansible-playbook -i inventories/prod/hosts.ini site.yml --ask-vault-pass
```

---
### Nota
Este proyecto es un **esqueleto** listo para producción ligera.
Para hardening adicional:
- restringir permisos del `.env`
- usar `ProtectSystem=strict` / `NoNewPrivileges=true` / `PrivateTmp=true` en systemd
- rotación de logs, healthchecks, firewall, etc.
