# Nombre del proyecto
NAME = inception

# Docker compose
COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_PATH = ./data

all: up

init_dirs:
	@echo "Creating data directories if not exist..."
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress

up: init_dirs
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build

start: init_dirs
	$(COMPOSE) up -d --build

stop:
	$(COMPOSE) stop

fclean:
	$(COMPOSE) down -v --remove-orphans
	@echo "Removing images..."
	-docker rmi -f mariadb:1.0 nginx:1.0 wordpress:1.0

	@echo "Removing volumes..."
	-docker volume rm -f srcs_mariadb_data srcs_wordpress_data

	@echo "Removing network..."
	-docker network rm srcs_inception

	@echo "Cleaning local data folders..."
	sudo rm -rf $(DATA_PATH)/mariadb
	sudo rm -rf $(DATA_PATH)/wordpress

	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress

	@echo "Pruning system..."
	docker system prune -a --volumes -f

re: fclean up

.PHONY: all up down build start stop clean fclean re init_dirs