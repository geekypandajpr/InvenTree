#!/bin/bash

# Easy script to run InvenTree with static IP address
# This script will start all services: database, backend server, worker, and frontend
# Configured to work with a static IP address

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

echo -e "${GREEN}InvenTree Static IP Setup${NC}"
echo "=========================================="
echo ""

# Check if docker.static-ip.env exists
ENV_FILE="$SCRIPT_DIR/docker.static-ip.env"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}Warning: docker.static-ip.env not found. Creating from template...${NC}"
    # Copy from template if it doesn't exist
    if [ -f "$SCRIPT_DIR/docker.local.env" ]; then
        cp "$SCRIPT_DIR/docker.local.env" "$ENV_FILE"
        echo -e "${YELLOW}Please edit $ENV_FILE and set STATIC_IP_ADDRESS to your actual static IP${NC}"
    else
        touch "$ENV_FILE"
    fi
fi

# Check if STATIC_IP_ADDRESS is set
if ! grep -q "STATIC_IP_ADDRESS=" "$ENV_FILE" || grep -q "STATIC_IP_ADDRESS=192.168.1.100" "$ENV_FILE"; then
    echo -e "${YELLOW}Warning: STATIC_IP_ADDRESS may not be configured correctly.${NC}"
    echo -e "${YELLOW}Please edit $ENV_FILE and set STATIC_IP_ADDRESS to your actual static IP address${NC}"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
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

# Extract static IP from env file
STATIC_IP=$(grep "^STATIC_IP_ADDRESS=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'" || echo "192.168.1.100")

# Process env file to substitute ${STATIC_IP_ADDRESS} variable references
# Create a temporary processed env file
PROCESSED_ENV_FILE="$SCRIPT_DIR/docker.static-ip.env.processed"
# Escape dots for regex substitution
STATIC_IP_ESCAPED=$(echo "$STATIC_IP" | sed 's/\./\\./g')

# Process the env file: substitute ${STATIC_IP_ADDRESS} and ${STATIC_IP_ADDRESS_ESCAPED} with actual IP
# Handle the special regex case where dots need to be escaped
sed -e "s|\${STATIC_IP_ADDRESS}|${STATIC_IP}|g" \
    -e "s|\${STATIC_IP_ADDRESS_ESCAPED}|${STATIC_IP_ESCAPED}|g" \
    "$ENV_FILE" > "$PROCESSED_ENV_FILE"

# Temporarily backup and replace the env file with processed version
cp "$ENV_FILE" "$ENV_FILE.backup"
cp "$PROCESSED_ENV_FILE" "$ENV_FILE"

# Function to restore original env file
restore_env_file() {
    if [ -f "$ENV_FILE.backup" ]; then
        mv "$ENV_FILE.backup" "$ENV_FILE"
    fi
    rm -f "$PROCESSED_ENV_FILE"
}

# Ensure cleanup on exit
trap "restore_env_file" EXIT INT TERM

echo -e "${GREEN}Starting InvenTree with static IP: ${STATIC_IP}${NC}"
echo ""
echo "Services:"
echo "  - Database (PostgreSQL) on port 5432"
echo "  - Backend server on http://${STATIC_IP}:8000"
echo "  - Frontend dev server on http://${STATIC_IP}:5173"
echo "  - Background worker"
echo ""
echo -e "${BLUE}Note: Make sure your firewall allows connections on ports 8000 and 5173${NC}"
echo ""

# Build and start services
$COMPOSE_CMD -f "$SCRIPT_DIR/static-ip-docker-compose.yml" up --build -d

# Restore original env file immediately after docker-compose reads it
restore_env_file

echo ""
echo -e "${GREEN}Services started successfully!${NC}"
echo ""
echo "Access the application:"
echo "  - Frontend: http://${STATIC_IP}:5173"
echo "  - Backend API: http://${STATIC_IP}:8000"
echo ""
echo "Useful commands:"
echo "  - View logs: $COMPOSE_CMD -f $SCRIPT_DIR/static-ip-docker-compose.yml logs -f"
echo "  - Stop services: $COMPOSE_CMD -f $SCRIPT_DIR/static-ip-docker-compose.yml down"
echo "  - Restart services: $COMPOSE_CMD -f $SCRIPT_DIR/static-ip-docker-compose.yml restart"
echo ""

# Show logs
echo -e "${GREEN}Showing logs (press Ctrl+C to exit)...${NC}"
$COMPOSE_CMD -f "$SCRIPT_DIR/static-ip-docker-compose.yml" logs -f

