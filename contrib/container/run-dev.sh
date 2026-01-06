#!/bin/bash

# Easy script to run InvenTree development environment with Docker Compose
# This script will start all services: database, backend server, worker, and frontend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

echo -e "${GREEN}InvenTree Development Environment Setup${NC}"
echo "=========================================="
echo ""

# Check if docker.local.env exists
ENV_FILE="$SCRIPT_DIR/docker.local.env"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}Warning: docker.local.env not found. Creating from template...${NC}"
    # The file should already exist, but just in case
    touch "$ENV_FILE"
fi

# Change to project root directory
cd "$PROJECT_ROOT"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: docker-compose is not installed. Please install it and try again.${NC}"
    exit 1
fi

# Use docker compose (v2) if available, otherwise use docker-compose (v1)
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo -e "${GREEN}Starting InvenTree development services...${NC}"
echo ""
echo "Services:"
echo "  - Database (PostgreSQL) on port 5432"
echo "  - Backend server on http://localhost:8000"
echo "  - Frontend dev server on http://localhost:5173"
echo "  - Background worker"
echo ""

# Build and start services
$COMPOSE_CMD -f "$SCRIPT_DIR/dev-docker-compose.yml" up --build -d

echo ""
echo -e "${GREEN}Services started successfully!${NC}"
echo ""
echo "Access the application:"
echo "  - Frontend: http://localhost:5173"
echo "  - Backend API: http://localhost:8000"
echo ""
echo "Useful commands:"
echo "  - View logs: $COMPOSE_CMD -f $SCRIPT_DIR/dev-docker-compose.yml logs -f"
echo "  - Stop services: $COMPOSE_CMD -f $SCRIPT_DIR/dev-docker-compose.yml down"
echo "  - Restart services: $COMPOSE_CMD -f $SCRIPT_DIR/dev-docker-compose.yml restart"
echo ""
echo -e "${YELLOW}Note: The frontend will automatically reload when you make changes to the code.${NC}"
echo ""

# Show logs
echo -e "${GREEN}Showing logs (press Ctrl+C to exit)...${NC}"
$COMPOSE_CMD -f "$SCRIPT_DIR/dev-docker-compose.yml" logs -f

