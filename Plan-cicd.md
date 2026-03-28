# Plan de Implementación CI/CD para Mindy

## Resumen

Este documento explica cómo implementar el pipeline de CI/CD completo para el proyecto Mindy (Django + PWA + Capacitor).

---

## Estructura de Repositorios

### Repo 1: jenkins-docker (este repositorio)
**Propósito**: Configuración de Jenkins y templates de deployment

| Archivo | Descripción |
|---------|-------------|
| `infra/Jenkinsfile` | Pipeline principal de CI/CD |
| `infra/Dockerfile.backend` | Template para construir imagen Docker de Django |
| `infra/docker-compose.staging.yml` | Configuración de entorno staging |
| `docker-compose.yml` | Jenkins local para desarrollo |

### Repo 2: Mindy-pwa-capacitor (repositorio del proyecto)
**Propósito**: Código fuente de la aplicación

| Archivo | Descripción |
|---------|-------------|
| `backend/` | Código Django |
| `frontend/` | Código PWA/Capacitor |
| `requirements.txt` | Dependencias Python |
| `infra/Jenkinsfile` | Pipeline de CI/CD (copiar carpeta infra completa) |
| `infra/Dockerfile.backend` | Para construir imagen |
| `infra/docker-compose.staging.yml` | Para staging |

---

## Paso 1: Configurar Jenkins Local

### Iniciar Jenkins
```bash
docker-compose up -d
```

### Obtener contraseña inicial
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Acceder a Jenkins
- URL: http://localhost:8080
- Usuario: admin (creado en setup inicial)

### Instalar Plugins necesarios
1. Ve a **Manage Jenkins → Manage Plugins**
2. Instala:
   - Docker Pipeline
   - Blue Ocean
   - Git
   - Pipeline

### Configurar Global Tools
**Manage Jenkins → Global Tool Configuration**

| Herramienta | Configuración |
|-------------|---------------|
| Python | Installation automatic |
| NodeJS | Installation automatic (v18) |

### Configurar Credenciales
**Manage Jenkins → Manage Credentials → Add Credentials**

| ID | Tipo | Descripción |
|----|------|-------------|
| `github-token` | Secret Text | Token de GitHub con acceso repo |
| `docker-registry` | Username/Password | Docker Hub o registry privado |
| `django-secret-key` | Secret Text | SECRET_KEY de Django |

---

## Paso 2: Copiar archivos al repo de Mindy

Copia la carpeta `infra/` completa desde `jenkins-docker` al repositorio `Mindy-pwa-capacitor`:

```
jenkins-docker/                    →  Mindy-pwa-capacitor/
└── infra/                         →  (raíz) infra/
    ├── Jenkinsfile               →  infra/Jenkinsfile
    ├── Dockerfile.backend        →  infra/Dockerfile.backend
    └── docker-compose.staging.yml →  infra/docker-compose.staging.yml
```

### O si prefieres, descarga directamente:
- https://raw.githubusercontent.com/ASamiraJasbonM/jenkins-docker/main/infra/Jenkinsfile
- https://raw.githubusercontent.com/ASamiraJasbonM/jenkins-docker/main/infra/Dockerfile.backend
- https://raw.githubusercontent.com/ASamiraJasbonM/jenkins-docker/main/infra/docker-compose.staging.yml

---

## Paso 3: Configurar el Pipeline en Jenkins

### Opción A: Pipeline desde SCM (Recomendado)

1. **New Item** → Nombre: `Mindy-CI-CD`
2. Selecciona: **Pipeline**
3. Configura:

```
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/ASamiraJasbonM/Mindy-pwa-capacitor.git
Credentials: github-token
Branches: */main
Script Path: infra/Jenkinsfile
```

### Opción B: Pipeline Inline

Copia el contenido del `Jenkinsfile` directamente en el campo "Script".

---

## Paso 4: Configurar Webhook en GitHub

1. Ve a tu repositorio: **Settings → Webhooks → Add webhook**
2. Configura:

| Campo | Valor |
|-------|-------|
| Payload URL | `http://TU-IP:8080/github-webhook/` |
| Content type | application/json |
| Events | Just the push event |

**Nota**: Si Jenkins está en tu PC local, usa ngrok:
```bash
ngrok http 8080
```
Usa la URL de ngrok para el webhook.

---

## Flujo de Trabajo

### Desarrollo Normal
```
1. Desarrollador hace cambios
   ↓
2. git add . && git commit -m "feat: nueva funcionalidad"
   ↓
3. git push origin main
   ↓
4. GitHub envía webhook a Jenkins
   ↓
5. Jenkins ejecuta el pipeline:
   - Checkout código
   - Instala dependencias Python
   - Ejecuta tests
   - Recopila staticfiles
   - Instala dependencias Node
   - Build PWA
   - Security checks
   - Linting
   ↓
6. Si todo OK → Despliega a staging
```

### Despliegue a Producción
```
1. En Jenkins, ejecuta el pipeline
2. Approve manual (configurado en Jenkinsfile)
3. Despliega a producción
```

---

## Comandos de Uso

### Desde la máquina con Jenkins

```bash
# Ver estado de Jenkins
docker-compose ps

# Ver logs
docker-compose logs -f

# Reiniciar Jenkins
docker-compose restart

# Acceder a Jenkins
open http://localhost:8080
```

### Desde el repo de Mindy (después de copiar archivos)

```bash
# Probar staging localmente
docker-compose -f infra/docker-compose.staging.yml up -d

# Ver logs del backend
docker logs -f mindy-backend

# Applied migraciones
docker exec mindy-backend python manage.py migrate
```

---

## Estructura del Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                     PIPELINE JENKINS                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐    ┌──────────────┐    ┌─────────────────┐   │
│  │Checkout │───▶│  Python Env   │───▶│ Backend Tests  │   │
│  └──────────┘    └──────────────┘    └─────────────────┘   │
│                                              │             │
│                                              ▼             │
│  ┌──────────┐    ┌──────────────┐    ┌─────────────────┐   │
│  │ Deploy   │◀───│ Health Check │◀───│ Static Files   │   │
│  │ Staging  │    └──────────────┘    └─────────────────┘   │
│  └──────────┘              ▲                               │
│        │                    │                               │
│        │              ┌─────┴─────┐                         │
│        │              │           │                         │
│        ▼              ▼           ▼                         │
│  ┌──────────┐    ┌──────────┐ ┌──────────┐                │
│  │ Production│   │Security  │ │Node Env  │                │
│  │(manual)  │   │ Checks   │ │+ Build   │                │
│  └──────────┘    └──────────┘ └──────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Resolución de Problemas

### Error: Git checkout fails
- Verificar que el `github-token` tenga permisos
- Verificar que la URL del repo sea correcta

### Error: Python dependencies fail
- Verificar que `requirements.txt` exista en el backend
- Verificar versión de Python

### Error: Node dependencies fail
- Verificar que `package.json` exista en el frontend
- Verificar Node version en Global Tools

### Error: Docker build fails
- Verificar que Docker esté corriendo
- Verificar credenciales de registry

### Error: Deployment fails
- Verificar que staging server esté accesible
- Verificar variables de entorno

---

## Configuración Adicional

### Variables de Entorno para Staging

Crea un archivo `.env` en el repo de Mindy:

```bash
# .env para staging
DB_PASSWORD=tu_password_seguro
SECRET_KEY=tu_secret_key_django
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1
```

### Para Producción

Agrega en Jenkinsfile:
```groovy
environment {
    DEBUG = 'False'
    ALLOWED_HOSTS = 'mindy.tudominio.com'
}
```

---

## Checklist de Implementación

- [ ] Jenkins corriendo localmente
- [ ] Plugins instalados
- [ ] Credenciales configuradas
- [ ] Archivos copiados al repo de Mindy
- [ ] Pipeline creado en Jenkins
- [ ] Webhook configurado en GitHub
- [ ] Primera ejecución exitosa
- [ ] Staging funcionando

---

## Siguientes Pasos (Opcionales)

1. **Agregar más stages**: Unit tests, integration tests, etc.
2. **Integrar con SonarQube**: Análisis de código
3. **Agregar Slack notifications**: Notificaciones de build
4. **Configurar backup automático**: De la base de datos
5. **Agregar monitoring**: Prometheus + Grafana

---

## Contacto y Soporte

Si tienes dudas sobre la implementación, revisa:
- Documentación de Jenkins: https://www.jenkins.io/doc/
- Docker Pipeline: https://www.jenkins.io/doc/book/pipeline/docker/
