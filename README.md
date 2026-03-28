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

## Estructura

- `jenkins_home` se guarda en un volumen Docker persistente
- Docker socket montado para permitir builds de contenedores

## Personalización

Para agregar plugins iniciales, crea un archivo `plugins.txt` y modifica el Dockerfile si es necesario.
