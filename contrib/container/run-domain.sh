#!/bin/bash

# Easy script to run InvenTree with domain name
# This script will start all services: database, backend server, worker, and frontend
# Configured to work with a domain name

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

echo -e "${GREEN}InvenTree Domain Setup${NC}"
echo "=========================================="
echo ""

# Check if docker.domain.env exists
ENV_FILE="$SCRIPT_DIR/docker.domain.env"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}Warning: docker.domain.env not found. Creating from template...${NC}"
    # Copy from template if it doesn't exist
    if [ -f "$SCRIPT_DIR/docker.local.env" ]; then
        cp "$SCRIPT_DIR/docker.local.env" "$ENV_FILE"
        echo -e "${YELLOW}Please edit $ENV_FILE and set DOMAIN_NAME to your actual domain${NC}"
    else
        touch "$ENV_FILE"
    fi
fi

# Check if DOMAIN_NAME is set
if ! grep -q "DOMAIN_NAME=" "$ENV_FILE" || grep -q "DOMAIN_NAME=inventree.example.com" "$ENV_FILE"; then
    echo -e "${YELLOW}Warning: DOMAIN_NAME may not be configured correctly.${NC}"
    echo -e "${YELLOW}Please edit $ENV_FILE and set DOMAIN_NAME to your actual domain name${NC}"
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

# Extract domain from env file
DOMAIN=$(grep "^DOMAIN_NAME=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'" || echo "inventree.example.com")

# Process env file to substitute ${DOMAIN_NAME} variable references
# Create a temporary processed env file
PROCESSED_ENV_FILE="$SCRIPT_DIR/docker.domain.env.processed"
# Escape dots for regex substitution
DOMAIN_ESCAPED=$(echo "$DOMAIN" | sed 's/\./\\./g')

# Process the env file: substitute ${DOMAIN_NAME} and ${DOMAIN_NAME_ESCAPED} with actual domain
# Handle the special regex case where dots need to be escaped
sed -e "s|\${DOMAIN_NAME}|${DOMAIN}|g" \
    -e "s|\${DOMAIN_NAME_ESCAPED}|${DOMAIN_ESCAPED}|g" \
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

echo -e "${GREEN}Starting InvenTree with domain: ${DOMAIN}${NC}"
echo ""
echo "Services:"
echo "  - Database (PostgreSQL) on port 5432"
echo "  - Backend server on http://${DOMAIN}:8000 (or https://${DOMAIN} if using reverse proxy)"
echo "  - Frontend dev server on http://${DOMAIN}:5173 (or https://${DOMAIN} if using reverse proxy)"
echo "  - Background worker"
echo ""
echo -e "${BLUE}Important Notes:${NC}"
echo "  - Make sure your domain DNS points to this server's IP address"
echo "  - For production, set up a reverse proxy (nginx/caddy) with SSL certificates"
echo "  - Update firewall rules to allow connections on ports 80, 443, 8000, and 5173"
echo "  - Consider using Let's Encrypt for SSL certificates"
echo ""

# Build and start services
$COMPOSE_CMD -f "$SCRIPT_DIR/domain-docker-compose.yml" up --build -d

# Restore original env file immediately after docker-compose reads it
restore_env_file

echo ""
echo -e "${GREEN}Services started successfully!${NC}"
echo ""
echo "Access the application:"
echo "  - Frontend: https://${DOMAIN} (or http://${DOMAIN}:5173 if not using reverse proxy)"
echo "  - Backend API: https://${DOMAIN} (or http://${DOMAIN}:8000 if not using reverse proxy)"
echo ""
echo "Useful commands:"
echo "  - View logs: $COMPOSE_CMD -f $SCRIPT_DIR/domain-docker-compose.yml logs -f"
echo "  - Stop services: $COMPOSE_CMD -f $SCRIPT_DIR/domain-docker-compose.yml down"
echo "  - Restart services: $COMPOSE_CMD -f $SCRIPT_DIR/domain-docker-compose.yml restart"
echo ""

# Show logs
echo -e "${GREEN}Showing logs (press Ctrl+C to exit)...${NC}"
$COMPOSE_CMD -f "$SCRIPT_DIR/domain-docker-compose.yml" logs -f

