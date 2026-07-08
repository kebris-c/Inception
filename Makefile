# =============================================================================
# Inception — Root Makefile
# =============================================================================
# PURPOSE: Single entry point to build and manage the entire Docker stack.
# RULE: Must build images via docker-compose.yml (subject requirement).
#
# USAGE (after completing):
#   make        → build images
#   make up     → start containers in background
#   make down   → stop containers
#   make logs   → follow all service logs
#   make re     → rebuild from scratch and restart
# =============================================================================

# Path to compose file (subject: compose lives in srcs/)
COMPOSE_FILE := srcs/docker-compose.yml

# TODO: Set your 42 login — used for volume paths if needed in targets
LOGIN ?= your_login

.PHONY: all build up down stop logs ps clean re

# Default target: build all images
all: build

# Build Docker images from Dockerfiles (no pull of ready-made app images)
build:
	@echo "TODO: docker compose -f $(COMPOSE_FILE) build"
	# docker compose -f $(COMPOSE_FILE) build

# Start the stack
up: build
	@echo "TODO: docker compose -f $(COMPOSE_FILE) up -d"
	# docker compose -f $(COMPOSE_FILE) up -d

# Stop containers (keep volumes)
down:
	@echo "TODO: docker compose -f $(COMPOSE_FILE) down"
	# docker compose -f $(COMPOSE_FILE) down

stop: down

# Stream logs from all services
logs:
	@echo "TODO: docker compose -f $(COMPOSE_FILE) logs -f"
	# docker compose -f $(COMPOSE_FILE) logs -f

# Show running containers
ps:
	@echo "TODO: docker compose -f $(COMPOSE_FILE) ps"
	# docker compose -f $(COMPOSE_FILE) ps

# Remove containers, networks, volumes, and locally built images (DESTRUCTIVE)
clean:
	@echo "TODO: docker compose -f $(COMPOSE_FILE) down -v --rmi local"
	# docker compose -f $(COMPOSE_FILE) down -v --rmi local

# Full reset: clean + build + up
re: clean build up
