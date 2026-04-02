# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/kgriset/data

# Phony targets ensure these names are always treated as commands, not files
.PHONY: all up down start stop clean fclean re logs

# The default rule when you just type 'make'
all: up

up:
	@echo "Creating data directories if they don't exist..."
	@sudo mkdir -p $(DATA_DIR)/wordpress
	@sudo mkdir -p $(DATA_DIR)/mariadb
	@echo "Starting Inception..."
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@echo "Stopping Inception..."
	docker compose -f $(COMPOSE_FILE) down

stop:
	@echo "Pausing Inception..."
	docker compose -f $(COMPOSE_FILE) stop

start:
	@echo "Resuming Inception..."
	docker compose -f $(COMPOSE_FILE) start

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down
	@echo "Cleaning up Docker environment..."
	docker system prune -a --force

fclean: clean
	@echo "Removing all data volumes..."
	@sudo rm -rf $(DATA_DIR)/wordpress/*
	@sudo rm -rf $(DATA_DIR)/mariadb/*
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all
