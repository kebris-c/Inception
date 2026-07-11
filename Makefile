# =============================================================================
# Inception — Root Makefile
# =============================================================================

COMPOSE_FILE := srcs/docker-compose.yml
LOGIN        := kebris-c
DATA_DIR     := /home/$(LOGIN)/data

.PHONY: all build up down stop logs ps clean re setup

all: build

setup:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@if [ ! -f srcs/.env ]; then cp srcs/.env.example srcs/.env; echo "Created srcs/.env"; fi
	@if [ ! -f secrets/db_password.txt ]; then openssl rand -base64 32 | tr -d '\n' > secrets/db_password.txt; fi
	@if [ ! -f secrets/db_root_password.txt ]; then openssl rand -base64 32 | tr -d '\n' > secrets/db_root_password.txt; fi
	@if [ ! -f secrets/wp_admin_password.txt ]; then openssl rand -base64 32 | tr -d '\n' > secrets/wp_admin_password.txt; fi
	@chmod 600 secrets/*.txt 2>/dev/null || true
	@echo "Setup complete. Add '$(shell hostname -I 2>/dev/null | awk '{print $$1}') $(LOGIN).42.fr' to /etc/hosts if needed."

build:
	docker compose -f $(COMPOSE_FILE) build

up: build
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

stop: down

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

ps:
	docker compose -f $(COMPOSE_FILE) ps

clean:
	docker compose -f $(COMPOSE_FILE) down -v --rmi local

re: clean build up
