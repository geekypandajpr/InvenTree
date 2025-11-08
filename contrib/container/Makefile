# Makefile for InvenTree Development and Production Commands
# Located in contrib/container/ to use same folder as docker-compose files
# Uses shell scripts for Docker commands to simplify path handling
#
# Usage:
#   cd contrib/container
#   make dev-docker
#   make prod-docker ENV_FILE=.env.prod

.PHONY: help dev-docker dev-docker-full dev-docker-custom prod-docker dev-dependencies stop-dependencies dev-backend dev-frontend dev-worker dev-all stop-docker clean-docker logs-docker

# Get the directory where this Makefile is located
CONTAINER_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECT_ROOT := $(abspath $(CONTAINER_DIR)/../..)

# Default target
help:
	@echo "InvenTree Run Commands"
	@echo "====================="
	@echo ""
	@echo "Location: contrib/container/"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make dev-docker          - Run backend only in Docker"
	@echo "  make dev-docker-full     - Run FULL STACK (Frontend + Backend) in Docker"
	@echo "  make dev-docker-custom   - Run dev with custom Dockerfile (env vars built-in)"
	@echo "  make prod-docker         - Run full production environment in Docker"
	@echo "  make dev-dependencies    - Run only dependencies (database, cache) in Docker"
	@echo "  make stop-docker         - Stop all Docker containers"
	@echo "  make clean-docker        - Stop and remove all Docker containers and volumes"
	@echo ""
	@echo "Local Development Commands (requires dependencies running):"
	@echo "  make dev-backend         - Run backend server locally in development mode"
	@echo "  make dev-frontend        - Run frontend server locally in development mode"
	@echo "  make dev-worker          - Run background worker locally"
	@echo "  make dev-all             - Run backend, frontend, and worker (in separate terminals)"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make stop-dependencies   - Stop only dependency containers"
	@echo "  make logs-docker         - View logs from Docker containers"
	@echo ""
	@echo "Environment File Support:"
	@echo "  - dev-docker: automatically uses docker.dev.env (in this folder)"
	@echo "  - prod-docker: automatically uses .env (in this folder, if exists)"
	@echo "  - dev-dependencies: automatically uses docker.dev.env (in this folder)"
	@echo ""
	@echo "  Override with ENV_FILE variable (relative to this folder or absolute path):"
	@echo "    make dev-docker ENV_FILE=.env.custom"
	@echo "    make prod-docker ENV_FILE=/absolute/path/to/.env.prod"
	@echo ""

# Docker Development Environment
# Uses run-docker-dev.sh script
dev-docker:
	@if [ -n "$(ENV_FILE)" ]; then \
		./run-docker-dev.sh "$(ENV_FILE)"; \
	else \
		./run-docker-dev.sh; \
	fi

# Docker Development Environment FULL STACK (Frontend + Backend)
# Runs both Django backend and Vite frontend with local source code
dev-docker-full:
	@if [ -n "$(ENV_FILE)" ]; then \
		./run-docker-full.sh "$(ENV_FILE)"; \
	else \
		./run-docker-full.sh; \
	fi

# Docker Development Environment (Custom Dockerfile)
# Uses Dockerfile.dev with all env vars built-in - no .env file needed!
dev-docker-custom:
	@./run-docker-dev-custom.sh

# Docker Production Environment
# Uses run-docker-prod.sh script
prod-docker:
	@if [ -n "$(ENV_FILE)" ]; then \
		./run-docker-prod.sh "$(ENV_FILE)"; \
	else \
		./run-docker-prod.sh; \
	fi

# Run only dependencies (database, cache) in Docker
# Uses run-dependencies.sh script
dev-dependencies:
	@if [ -n "$(ENV_FILE)" ]; then \
		./run-dependencies.sh "$(ENV_FILE)"; \
	else \
		./run-dependencies.sh; \
	fi

# Stop dependency containers
stop-dependencies:
	@echo "🛑 Stopping dependency containers..."
	@if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then \
		docker compose -f dev-docker-compose.yml stop inventree-dev-db 2>/dev/null || true; \
	elif command -v docker-compose &> /dev/null; then \
		docker-compose -f dev-docker-compose.yml stop inventree-dev-db 2>/dev/null || true; \
	fi
	@echo "✅ Dependencies stopped"

# Stop all Docker containers
stop-docker:
	@echo "🛑 Stopping all Docker containers..."
	@if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then \
		docker compose -f dev-docker-compose.yml down 2>/dev/null || true; \
		docker compose -f docker-compose.yml down 2>/dev/null || true; \
	elif command -v docker-compose &> /dev/null; then \
		docker-compose -f dev-docker-compose.yml down 2>/dev/null || true; \
		docker-compose -f docker-compose.yml down 2>/dev/null || true; \
	fi
	@echo "✅ All containers stopped"

# Clean Docker containers and volumes
clean-docker:
	@echo "🧹 Cleaning Docker containers and volumes..."
	@if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then \
		docker compose -f dev-docker-compose.yml down -v 2>/dev/null || true; \
		docker compose -f docker-compose.yml down -v 2>/dev/null || true; \
	elif command -v docker-compose &> /dev/null; then \
		docker-compose -f dev-docker-compose.yml down -v 2>/dev/null || true; \
		docker-compose -f docker-compose.yml down -v 2>/dev/null || true; \
	fi
	@echo "✅ Docker cleanup complete"

# View Docker logs
logs-docker:
	@echo "📋 Viewing Docker logs..."
	@if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then \
		docker compose -f dev-docker-compose.yml logs -f 2>/dev/null || \
		docker compose -f docker-compose.yml logs -f 2>/dev/null || true; \
	elif command -v docker-compose &> /dev/null; then \
		docker-compose -f dev-docker-compose.yml logs -f 2>/dev/null || \
		docker-compose -f docker-compose.yml logs -f 2>/dev/null || true; \
	fi

# Local Development - Backend
# Changes to project root and uses docker.dev.env from container folder
dev-backend:
	@echo "🚀 Starting InvenTree Backend in Development Mode..."
	@ENV_FILE_PATH=""; \
	CONTAINER_DIR="$(CONTAINER_DIR)"; \
	if [ -n "$(ENV_FILE)" ]; then \
		if [ -f "$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$(ENV_FILE)"; \
		elif [ -f "$$CONTAINER_DIR/$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$$CONTAINER_DIR/$(ENV_FILE)"; \
		fi; \
	elif [ -f "$$CONTAINER_DIR/docker.dev.env" ]; then \
		ENV_FILE_PATH="$$CONTAINER_DIR/docker.dev.env"; \
	fi; \
	if [ -n "$$ENV_FILE_PATH" ]; then \
		echo "📄 Loading env file: $$ENV_FILE_PATH"; \
		set -a && source "$$ENV_FILE_PATH" && set +a; \
	fi
	@cd "$(PROJECT_ROOT)" && \
	if command -v invoke &> /dev/null; then \
		invoke dev.server; \
	else \
		echo "❌ Error: 'invoke' command not found. Please install it: pip install invoke"; \
		exit 1; \
	fi

# Local Development - Frontend
# Changes to project root
dev-frontend:
	@echo "🚀 Starting InvenTree Frontend in Development Mode..."
	@ENV_FILE_PATH=""; \
	CONTAINER_DIR="$(CONTAINER_DIR)"; \
	if [ -n "$(ENV_FILE)" ]; then \
		if [ -f "$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$(ENV_FILE)"; \
		elif [ -f "$$CONTAINER_DIR/$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$$CONTAINER_DIR/$(ENV_FILE)"; \
		fi; \
	fi; \
	if [ -n "$$ENV_FILE_PATH" ]; then \
		echo "📄 Loading env file: $$ENV_FILE_PATH"; \
		set -a && source "$$ENV_FILE_PATH" && set +a; \
	fi
	@cd "$(PROJECT_ROOT)" && \
	if command -v invoke &> /dev/null; then \
		invoke dev.frontend-server; \
	elif command -v yarn &> /dev/null; then \
		cd src/frontend && yarn run compile && yarn run dev --host; \
	else \
		echo "❌ Error: 'yarn' or 'invoke' command not found"; \
		exit 1; \
	fi

# Local Development - Worker
# Changes to project root and uses docker.dev.env from container folder
dev-worker:
	@echo "⚙️  Starting InvenTree Background Worker..."
	@ENV_FILE_PATH=""; \
	CONTAINER_DIR="$(CONTAINER_DIR)"; \
	if [ -n "$(ENV_FILE)" ]; then \
		if [ -f "$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$(ENV_FILE)"; \
		elif [ -f "$$CONTAINER_DIR/$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$$CONTAINER_DIR/$(ENV_FILE)"; \
		fi; \
	elif [ -f "$$CONTAINER_DIR/docker.dev.env" ]; then \
		ENV_FILE_PATH="$$CONTAINER_DIR/docker.dev.env"; \
	fi; \
	if [ -n "$$ENV_FILE_PATH" ]; then \
		echo "📄 Loading env file: $$ENV_FILE_PATH"; \
		set -a && source "$$ENV_FILE_PATH" && set +a; \
	fi
	@cd "$(PROJECT_ROOT)" && \
	if command -v invoke &> /dev/null; then \
		invoke worker; \
	else \
		echo "❌ Error: 'invoke' command not found. Please install it: pip install invoke"; \
		exit 1; \
	fi

# Run all local development services (requires 3 terminals)
dev-all:
	@echo "🚀 Starting all local development services..."
	@echo ""
	@echo "⚠️  This requires 3 separate terminal windows:"
	@echo ""
	@echo "Terminal 1 - Backend:"
	@echo "  make dev-backend"
	@echo ""
	@echo "Terminal 2 - Frontend:"
	@echo "  make dev-frontend"
	@echo ""
	@echo "Terminal 3 - Worker:"
	@echo "  make dev-worker"
	@echo ""
	@echo "Or use a terminal multiplexer like tmux or screen"
	@echo ""
	@ENV_FILE_PATH=""; \
	CONTAINER_DIR="$(CONTAINER_DIR)"; \
	if [ -n "$(ENV_FILE)" ]; then \
		if [ -f "$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$(ENV_FILE)"; \
		elif [ -f "$$CONTAINER_DIR/$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$$CONTAINER_DIR/$(ENV_FILE)"; \
		fi; \
	elif [ -f "$$CONTAINER_DIR/docker.dev.env" ]; then \
		ENV_FILE_PATH="$$CONTAINER_DIR/docker.dev.env"; \
	fi; \
	if [ -n "$$ENV_FILE_PATH" ]; then \
		echo "Using env file: $$ENV_FILE_PATH"; \
		echo ""; \
	fi
	@read -p "Press Enter to start backend in this terminal, or Ctrl+C to cancel..."
	@ENV_FILE_PATH=""; \
	CONTAINER_DIR="$(CONTAINER_DIR)"; \
	if [ -n "$(ENV_FILE)" ]; then \
		if [ -f "$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$(ENV_FILE)"; \
		elif [ -f "$$CONTAINER_DIR/$(ENV_FILE)" ]; then \
			ENV_FILE_PATH="$$CONTAINER_DIR/$(ENV_FILE)"; \
		fi; \
	elif [ -f "$$CONTAINER_DIR/docker.dev.env" ]; then \
		ENV_FILE_PATH="$$CONTAINER_DIR/docker.dev.env"; \
	fi; \
	cd "$(PROJECT_ROOT)" && \
	if [ -n "$$ENV_FILE_PATH" ]; then \
		set -a && source "$$ENV_FILE_PATH" && set +a && invoke dev.server; \
	else \
		invoke dev.server; \
	fi
