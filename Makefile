# Makefile for InvenTree Development and Production Commands
# This Makefile delegates to the Makefile in contrib/container/
# For direct usage, go to contrib/container/ and use that Makefile
#
# Usage:
#   cd contrib/container && make dev-docker
#   Or from project root: make -C contrib/container dev-docker

.PHONY: help dev-docker prod-docker dev-dependencies stop-dependencies dev-backend dev-frontend dev-worker dev-all stop-docker clean-docker logs-docker

# Default target
help:
	@echo "InvenTree Run Commands"
	@echo "====================="
	@echo ""
	@echo "This Makefile delegates to contrib/container/Makefile"
	@echo ""
	@echo "Recommended usage:"
	@echo "  cd contrib/container"
	@echo "  make dev-docker"
	@echo ""
	@echo "Or from project root:"
	@echo "  make -C contrib/container dev-docker"
	@echo ""
	@echo "For full help, run:"
	@echo "  cd contrib/container && make help"
	@echo ""

# Delegate all commands to contrib/container/Makefile
dev-docker prod-docker dev-dependencies stop-dependencies stop-docker clean-docker logs-docker dev-backend dev-frontend dev-worker dev-all:
	@$(MAKE) -C contrib/container $@ ENV_FILE=$(ENV_FILE)
