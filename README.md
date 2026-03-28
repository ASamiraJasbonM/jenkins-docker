# Jenkins CI/CD con Docker Compose

## Requisitos

- Docker 20.10+
- Docker Compose 2.0+

## Inicio Rápido

```bash
# Iniciar Jenkins
docker-compose up -d

# Ver logs
docker-compose logs -f

# Obtener contraseña inicial
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## Acceso

- **Jenkins**: http://localhost:8080
- **Puerto 50000**: Para agentes Jenkins

## Comandos

```bash
# Iniciar
docker-compose up -d

# Detener
docker-compose down

# Detener y eliminar datos
docker-compose down -v

# Reiniciar
docker-compose restart

# Ver logs
docker-compose logs -f jenkins

# Obtener contraseña admin
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Ejecutar comandos dentro del contenedor
docker exec -it jenkins bash
```

## Estructura del Proyecto

```
.
├── docker-compose.yml          # Jenkins local para desarrollo
├── infra/                      # Templates de CI/CD para Mindy
│   ├── Jenkinsfile             # Pipeline de CI/CD
│   ├── Dockerfile.backend      # Imagen Docker para Django
│   └── docker-compose.staging.yml  # Entorno staging
├── Makefile                   # Comandos útiles
├── Plan-cicd.md              # Plan de implementación
└── README.md
```

## Carpeta infra/

Esta carpeta contiene los archivos necesarios para configurar el pipeline de CI/CD del proyecto Mindy:

| Archivo | Descripción |
|---------|-------------|
| `Jenkinsfile` | Pipeline completo de CI/CD |
| `Dockerfile.backend` | Template para construir imagen Docker |
| `docker-compose.staging.yml` | Configuración de entorno staging |

Para usar estos archivos en el proyecto Mindy, copia la carpeta `infra/` completa al repositorio del proyecto.

## Personalización

Para agregar plugins iniciales, crea un archivo `plugins.txt` y modifica el Dockerfile si es necesario.
