# ansible-deploy 🚀

Proyecto Ansible que clona cualquier repositorio Git y lo inicia automáticamente según el tipo de proyecto detectado.

## Tipos de proyecto soportados

| Indicador detectado       | Tipo           | Cómo se inicia                  |
|---------------------------|----------------|---------------------------------|
| `package.json`            | Node.js        | PM2                             |
| `manage.py`               | Django         | Gunicorn + systemd              |
| `app.py` / `wsgi.py`      | Flask/WSGI     | Gunicorn (daemon)               |
| `requirements.txt`        | Python genérico| Python directo (`main.py`)      |
| `pom.xml`                 | Java Maven     | `java -jar` tras `mvn package` |
| `build.gradle`            | Java Gradle    | `java -jar` tras `gradle build` |
| `composer.json`           | PHP            | PHP-FPM + Nginx                 |
| `index.html`              | Estático       | Nginx                           |

## Estructura del proyecto

```
ansible-deploy/
├── site.yml                  # Playbook principal
├── ansible.cfg               # Configuración Ansible
├── inventory/
│   └── hosts.ini             # Inventario de servidores
├── group_vars/
│   └── all.yml               # Variables globales
└── roles/
    ├── clone_repo/           # Clona/actualiza el repositorio
    ├── detect_project/       # Detecta el tipo de proyecto
    └── start_project/       # Inicia el proyecto según su tipo
        ├── tasks/
        │   ├── main.yml
        │   ├── node.yml
        │   ├── python_django.yml
        │   ├── python_flask.yml
        │   ├── python_generic.yml
        │   ├── java_maven.yml
        │   ├── java_gradle.yml
        │   ├── php.yml
        │   └── static.yml
        ├── templates/
        │   └── gunicorn.service.j2
        └── handlers/
            └── main.yml
```

## Uso

### 1. Configurar el inventario
Edita `inventory/hosts.ini` y añade tus servidores:
```ini
[targets]
mi-servidor ansible_host=192.168.1.10 ansible_user=ubuntu
```

### 2. Ejecutar el playbook
```bash
# Con los valores por defecto definidos en site.yml
ansible-playbook site.yml

# Especificando repositorio y directorio destino
ansible-playbook site.yml \
  -e "repo_url=https://github.com/usuario/mi-proyecto" \
  -e "dest=/opt/mi-app" \
  -e "branch=main" \
  -e "app_port=8080"
```

### 3. Prueba local
```bash
# Asegúrate de que el inventario apunte a localhost
ansible-playbook site.yml \
  -e "repo_url=https://github.com/usuario/mi-proyecto" \
  -e "dest=/tmp/test-app"
```

## Variables disponibles

| Variable      | Default                               | Descripción                         |
|---------------|---------------------------------------|-------------------------------------|
| `repo_url`    | `https://github.com/user/my-project`  | URL del repositorio Git             |
| `dest`        | `/opt/deployed_app`                   | Directorio de instalación           |
| `branch`      | `main`                                | Rama a clonar                       |
| `app_port`    | `3000`                                | Puerto de la aplicación             |
| `node_version`| `20`                                  | Versión de Node.js                  |
| `python_bin`  | `python3`                             | Intérprete Python                   |
| `app_user`    | `www-data`                            | Usuario del sistema para la app     |

## Requisitos

- Ansible ≥ 2.12
- Colección `community.general` para el módulo `npm`:
  ```bash
  ansible-galaxy collection install community.general
  ```
- Acceso SSH con privilegios `sudo` a los servidores destino
