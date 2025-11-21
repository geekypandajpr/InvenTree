#!/bin/bash

# Script to run only dependencies (database, cache) for InvenTree
# Uses docker.dev.env from the same folder by default
# This is useful when you want to run the application locally but use Docker for dependencies
#
# Usage:
#   ./run-dependencies.sh [ENV_FILE]
#   ./run-dependencies.sh
#   ./run-dependencies.sh .env.custom

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default env file
DEFAULT_ENV_FILE="docker.dev.env"
ENV_FILE="${1:-$DEFAULT_ENV_FILE}"

# Resolve env file path
ENV_FILE_PATH=""
if [ -f "$ENV_FILE" ]; then
    ENV_FILE_PATH="$ENV_FILE"
elif [ -f "$SCRIPT_DIR/$ENV_FILE" ]; then
    ENV_FILE_PATH="$SCRIPT_DIR/$ENV_FILE"
elif [ "$ENV_FILE" != "$DEFAULT_ENV_FILE" ]; then
    echo "⚠️  Warning: Env file not found: $ENV_FILE"
    echo "   Using default: $DEFAULT_ENV_FILE"
    ENV_FILE="$DEFAULT_ENV_FILE"
fi

# Use default if not found
if [ -z "$ENV_FILE_PATH" ] && [ -f "$SCRIPT_DIR/$DEFAULT_ENV_FILE" ]; then
    ENV_FILE_PATH="$SCRIPT_DIR/$DEFAULT_ENV_FILE"
fi

echo "🐳 Starting InvenTree Dependencies (Database, Cache)..."
echo "📁 Directory: $SCRIPT_DIR"
if [ -n "$ENV_FILE_PATH" ]; then
    echo "📄 Loading env file: $ENV_FILE_PATH"
    set -a
    source "$ENV_FILE_PATH"
    set +a
fi
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH"
    exit 1
fi

# Use docker compose (newer) or docker-compose (older)
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "❌ Error: docker compose or docker-compose not found"
    exit 1
fi

# Run only database service
echo "🚀 Starting dependency services (database)..."
echo "   - Database will be available at localhost:5432"
echo ""

$COMPOSE_CMD -f dev-docker-compose.yml up -d inventree-dev-db

echo ""
echo "✅ Dependencies started!"
echo ""
echo "📝 Database connection details:"
echo "   Host: localhost"
echo "   Port: 5432"
echo "   Database: inventree"
echo "   User: pguser"
echo "   Password: pgpassword"
echo ""
echo "💡 You can now run the backend and frontend locally using:"
echo "   cd contrib/container && make dev-backend"
echo "   cd contrib/container && make dev-frontend"
echo ""

