.PHONY: help start stop restart logs status clean password

help:
	@echo "Jenkins Docker Compose - Comandos disponibles:"
	@echo "  make start     - Iniciar Jenkins"
	@echo "  make stop      - Detener Jenkins"
	@echo "  make restart  - Reiniciar Jenkins"
	@echo "  make logs     - Ver logs de Jenkins"
	@echo "  make status   - Ver estado de contenedores"
	@echo "  make password - Mostrar contraseña inicial"
	@echo "  make clean    - Eliminar todo (incluye datos)"

start:
	docker-compose up -d

stop:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

status:
	docker-compose ps

password:
	@echo "Contraseña inicial de Jenkins:"
	@docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

clean:
	docker-compose down -v
