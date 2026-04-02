COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data

# List of all data subdirectories for our volumes
VOL_DIRS = $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb $(DATA_DIR)/portainer

.PHONY: all up down start stop clean fclean re logs

# Default rule
all: up

up:
	@echo "Creating data directories at $(DATA_DIR)..."
	@sudo mkdir -p $(VOL_DIRS)
	@sudo chmod -R 777 $(DATA_DIR)
	@echo "Starting all Inception services (including bonuses)..."
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@echo "Stopping Inception..."
	docker compose -f $(COMPOSE_FILE) down

stop:
	@echo "Pausing containers..."
	docker compose -f $(COMPOSE_FILE) stop

start:
	@echo "Resuming containers..."
	docker compose -f $(COMPOSE_FILE) start

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down
	@echo "Cleaning up Docker environment (images and networks)..."
	docker system prune -a --force

fclean: down
	@echo " FULL PURGE: Removing all data and volumes... "
	# Remove the actual files on the host
	@sudo rm -rf $(DATA_DIR)
	# Remove the docker volumes themselves
	@if [ $$(docker volume ls -q | wc -l) -gt 0 ]; then \
		docker volume rm $$(docker volume ls -q); \
	fi
	@echo "System is clean."

re: fclean all
