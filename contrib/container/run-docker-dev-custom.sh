#!/bin/bash

# Script to run InvenTree development environment using Docker Compose
# Uses Dockerfile.dev which has all environment variables built-in
# No need for external .env files!
#
# Usage:
#   ./run-docker-dev-custom.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🐳 Starting InvenTree Development Docker Environment (Custom Dockerfile)..."
echo "📁 Directory: $SCRIPT_DIR"
echo "📄 Using Dockerfile.dev with built-in environment variables"
echo "   No external .env file needed!"
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

# Run docker compose with custom dockerfile
echo "🚀 Starting services..."
$COMPOSE_CMD -f dev-docker-compose.custom.yml up --build

