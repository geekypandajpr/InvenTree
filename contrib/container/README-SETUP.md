# InvenTree Docker Setup Scripts

This directory contains multiple setup scripts for running InvenTree in different configurations:

## Available Scripts

### 1. Development Setup (Localhost)
**Script:** `run-dev.sh`  
**Config:** `docker.local.env`  
**Compose:** `dev-docker-compose.yml`

Runs InvenTree for local development on `localhost`.

**Usage:**
```bash
./run-dev.sh
```

**Access:**
- Frontend: http://localhost:5173
- Backend: http://localhost:8000

---

### 2. Static IP Setup
**Script:** `run-static-ip.sh`  
**Config:** `docker.static-ip.env`  
**Compose:** `static-ip-docker-compose.yml`

Runs InvenTree accessible via a static IP address (e.g., on a local network).

**Setup Steps:**
1. Edit `docker.static-ip.env`
2. Replace `192.168.1.100` with your actual static IP address in all places:
   - `STATIC_IP_ADDRESS=192.168.1.100`
   - `INVENTREE_SITE_URL=http://192.168.1.100:8000`
   - `INVENTREE_CORS_ORIGIN_WHITELIST=http://192.168.1.100:8000,http://192.168.1.100:5173`
   - `INVENTREE_ALLOWED_HOSTS=192.168.1.100,localhost,127.0.0.1`
   - `INVENTREE_TRUSTED_ORIGINS=http://192.168.1.100:8000,http://192.168.1.100:5173`

**Usage:**
```bash
./run-static-ip.sh
```

**Access:**
- Frontend: http://YOUR_STATIC_IP:5173
- Backend: http://YOUR_STATIC_IP:8000

**Note:** Make sure your firewall allows connections on ports 8000 and 5173.

---

### 3. Domain Setup
**Script:** `run-domain.sh`  
**Config:** `docker.domain.env`  
**Compose:** `domain-docker-compose.yml`

Runs InvenTree accessible via a domain name (for production or staging).

**Setup Steps:**
1. Edit `docker.domain.env`
2. Replace `inventree.example.com` with your actual domain name in all places:
   - `DOMAIN_NAME=inventree.example.com`
   - `INVENTREE_SITE_URL=https://inventree.example.com`
   - `INVENTREE_CORS_ORIGIN_WHITELIST=https://inventree.example.com,http://inventree.example.com`
   - `INVENTREE_ALLOWED_HOSTS=inventree.example.com,www.inventree.example.com,localhost,127.0.0.1`
   - `INVENTREE_TRUSTED_ORIGINS=https://inventree.example.com,http://inventree.example.com,...`
   - `INVENTREE_ADMIN_EMAIL=admin@inventree.example.com`

**Usage:**
```bash
./run-domain.sh
```

**Access:**
- Frontend: https://YOUR_DOMAIN (or http://YOUR_DOMAIN:5173 if not using reverse proxy)
- Backend: https://YOUR_DOMAIN (or http://YOUR_DOMAIN:8000 if not using reverse proxy)

**Important Notes:**
- Make sure your domain DNS points to this server's IP address
- For production, set up a reverse proxy (nginx/caddy) with SSL certificates
- Consider using Let's Encrypt for SSL certificates
- Update firewall rules to allow connections on ports 80, 443, 8000, and 5173

---

## Common Commands

### View Logs
```bash
# Development
docker compose -f contrib/container/dev-docker-compose.yml logs -f

# Static IP
docker compose -f contrib/container/static-ip-docker-compose.yml logs -f

# Domain
docker compose -f contrib/container/domain-docker-compose.yml logs -f
```

### Stop Services
```bash
# Development
docker compose -f contrib/container/dev-docker-compose.yml down

# Static IP
docker compose -f contrib/container/static-ip-docker-compose.yml down

# Domain
docker compose -f contrib/container/domain-docker-compose.yml down
```

### Restart Services
```bash
# Development
docker compose -f contrib/container/dev-docker-compose.yml restart

# Static IP
docker compose -f contrib/container/static-ip-docker-compose.yml restart

# Domain
docker compose -f contrib/container/domain-docker-compose.yml restart
```

---

## Configuration Files

Each setup has its own environment file:
- `docker.local.env` - Development/localhost configuration
- `docker.static-ip.env` - Static IP configuration
- `docker.domain.env` - Domain configuration

All configuration files support the same environment variables. Key variables include:

- `INVENTREE_SITE_URL` - Base URL for the InvenTree instance
- `INVENTREE_DEBUG` - Enable/disable debug mode
- `INVENTREE_ALLOWED_HOSTS` - Comma-separated list of allowed hosts
- `INVENTREE_CORS_ORIGIN_WHITELIST` - Comma-separated list of allowed CORS origins
- `INVENTREE_TRUSTED_ORIGINS` - Comma-separated list of CSRF trusted origins
- Database configuration variables (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, etc.)

---

## Troubleshooting

### Port Already in Use
If you get port conflicts, you can change the ports in the docker-compose files:
- Backend: Change `8000:8000` to `YOUR_PORT:8000`
- Frontend: Change `5173:5173` to `YOUR_PORT:5173`
- Database: Change `5432:5432` to `YOUR_PORT:5432`

### CORS Issues
Make sure your `INVENTREE_CORS_ORIGIN_WHITELIST` and `INVENTREE_TRUSTED_ORIGINS` include all the URLs you're accessing the application from.

### Database Connection Issues
Verify that:
- Database container is running
- Database credentials in the env file match the docker-compose configuration
- Database host name matches the service name in docker-compose

---

## Data Persistence

Each setup uses separate data directories:
- Development: `./data/`
- Static IP: `./data-static-ip/`
- Domain: `./data-domain/`

This ensures that data from different setups doesn't interfere with each other.

