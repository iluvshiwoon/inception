# Inception - Developer Documentation

## Prerequisites

### Required Software

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version
```

Expected minimum versions:
- Docker: 20.x or higher
- Docker Compose: 2.x or higher

### VM Requirements

This project must be run on a Virtual Machine. The evaluation expects:
- A clean VM environment
- Ability to run Docker and Docker Compose
- Network access for pulling Debian base images

---

## Environment Setup from Scratch

### Step 1: Clone Repository

```bash
cd ~
git clone <repository_url> inception
cd inception
```

### Step 2: Create Data Directories

```bash
mkdir -p ~/data/wordpress
mkdir -p ~/data/mariadb
mkdir -p ~/data/portainer

# Set permissions
chmod -R 777 ~/data
```

Note: These directories are where Docker volumes will store persistent data via the bind volume driver.

### Step 3: Configure Environment Variables

Create the `.env` file at `srcs/.env`:

```bash
cd ~/inception/srcs
cat > .env << 'EOF'
DOMAIN_NAME=kgriset.42.fr

# Database configuration
SQL_DATABASE=wordpress_db
SQL_USER=wp_user
SQL_PASSWORD=your_password_here
SQL_ROOT_PASSWORD=your_root_password_here

# WordPress configuration
WP_URL=https://kgriset.42.fr
WP_TITLE=Inception
WP_ADMIN_USER=your_admin_username
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=your_email@student.42.fr

# Regular WordPress user (optional)
WP_USER=regular_user
WP_USER_PASSWORD=your_user_password
WP_USER_EMAIL=your_email@student.42.fr

# FTP configuration
FTP_USER=ftp_username
FTP_PASSWORD=ftp_password
EOF
```

**Security Note**: The `.env` file is excluded from git via `.gitignore`. Never commit credentials to version control.

---

## Building and Launching

### Build and Start All Services

```bash
cd ~/inception
make up
```

This executes:
1. `sudo mkdir -p ~/data/wordpress ~/data/mariadb ~/data/portainer`
2. `docker compose -f srcs/docker-compose.yml up -d --build`

### Manual Build (Alternative)

```bash
cd ~/inception/srcs
docker compose up -d --build
```

### Verify Build Success

```bash
docker ps
```

Should show all 8 containers: nginx, wordpress, mariadb, redis, ftp, adminer, portainer, static_site

---

## Container Management

### Check Container Status

```bash
docker ps                    # Running containers
docker ps -a                 # All containers (including stopped)
docker compose -f srcs/docker-compose.yml ps
```

### View Container Logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs

# Specific service
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs redis

# Follow logs in real-time
docker compose -f srcs/docker-compose.yml logs -f
```

### Shell Into Container

```bash
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
docker exec -it redis sh
```

### Restart Specific Service

```bash
docker compose -f srcs/docker-compose.yml restart nginx
docker compose -f srcs/docker-compose.yml restart wordpress
```

### Rebuild Service

```bash
docker compose -f srcs/docker-compose.yml up -d --build nginx
```

---

## Volume Management

### List Volumes

```bash
docker volume ls
```

Expected volumes:
- db_data (MariaDB)
- wp_data (WordPress)
- portainer_data (Portainer)

### Inspect Volume

```bash
docker volume inspect db_data
docker volume inspect wp_data
docker volume inspect portainer_data
```

### Check Volume Mount Location

The volumes store data at `/home/kgriset/data/` on the host:
- db_data → /home/kgriset/data/mariadb
- wp_data → /home/kgriset/data/wordpress
- portainer_data → /home/kgriset/data/portainer

```bash
# Verify data directories exist
ls -la ~/data/
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
```

---

## Network Management

### List Networks

```bash
docker network ls
```

Expected: inception_network with bridge driver

### Inspect Network

```bash
docker network inspect inception_network
```

This shows all containers connected to the network and their IP addresses.

---

## Service-Specific Commands

### WordPress (WP-CLI)

```bash
# Check WordPress version
docker exec wordpress wp --allow-root core version

# List users
docker exec wordpress wp --allow-root user list

# Create a new post
docker exec wordpress wp --allow-root post create --post_title="New Post" --post_content="Content here" --post_status=publish

# List posts
docker exec wordpress wp --allow-root post list

# Update a post
docker exec wordpress wp --allow-root post update <post_id> --post_title="Updated Title"

# Install a plugin
docker exec wordpress wp --allow-root plugin install <plugin-name> --activate

# Check Redis cache status
docker exec wordpress wp --allow-root redis status
```

### MariaDB

```bash
# Connect to database
docker exec -it mariadb mysql -u root -p

# Show databases
docker exec mariadb mysql -u root -e "SHOW DATABASES;"

# Show tables in WordPress database
docker exec mariadb mysql -u root wordpress_db -e "SHOW TABLES;"

# Execute SQL query
docker exec mariadb mysql -u root -e "SELECT COUNT(*) FROM wordpress_db.wp_users;"
```

### Redis

```bash
# Connect to Redis
docker exec -it redis redis-cli

# Test connection
docker exec redis redis-cli ping

# View Redis info
docker exec redis redis-cli info
```

---

## Data Persistence

### How Persistence Works

1. **Docker Named Volumes with Bind Driver**: The docker-compose.yml defines volumes with:
   ```yaml
   volumes:
     db_data:
       driver: local
       driver_opts:
         type: none
         o: bind
         device: /home/kgriset/data/mariadb
   ```

2. **Data Location**: All persistent data is stored at `/home/kgriset/data/` on the host machine.

3. **Survives**: Container restarts, container removal, and VM reboots.

### Test Persistence

```bash
# 1. Create test data
docker exec wordpress wp --allow-root post create --post_title="Test Persistence" --post_content="Testing if data persists" --post_status=publish

# 2. Stop containers
make down
# or: docker compose -f srcs/docker-compose.yml down

# 3. Verify containers stopped
docker ps

# 4. Restart
make up
# or: docker compose -f srcs/docker-compose.yml up -d

# 5. Verify data persisted
docker exec wordpress wp --allow-root post list | grep "Test Persistence"
```

---

## Project Structure Overview

```
inception/
├── Makefile                    # Main entry point
├── .gitignore                  # Excludes .env and secrets/
├── USER_DOC.md                 # User documentation
├── DEV_DOC.md                  # This file
├── srcs/
│   ├── docker-compose.yml      # Service definitions
│   ├── .env                    # Environment variables (NOT in git)
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   └── conf/
│       │       └── nginx.conf
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── www.conf
│       │   └── tools/
│       │       └── wp_setup.sh
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── 50-server.cnf
│       │   └── tools/
│       │       └── mariadb.sh
│       └── bonus/
│           ├── redis/
│           ├── ftp/
│           ├── adminer/
│           ├── portainer/
│           └── static/
```

---

## Development Workflow

### Making Changes

1. **Edit Configuration**: Modify files in `srcs/requirements/<service>/`

2. **Rebuild**: 
   ```bash
   docker compose -f srcs/docker-compose.yml up -d --build <service>
   ```

3. **Test**: Verify the change works as expected

4. **Commit**: Add and commit changes to git

### Adding a New Service

1. Create directory: `srcs/requirements/<service_name>/`
2. Create Dockerfile
3. Add service definition to `srcs/docker-compose.yml`
4. Add to Makefile if needed
5. Rebuild: `docker compose -f srcs/docker-compose.yml up -d --build <service_name>`

### Debugging

```bash
# Check logs
docker logs <container_name>

# Check environment variables inside container
docker exec <container_name> env

# Check network connectivity between containers
docker exec nginx ping wordpress
docker exec wordpress ping mariadb

# Inspect container details
docker inspect <container_name>
```

---

## Cleanup Commands

### Stop and Remove Containers

```bash
make down
# or: docker compose -f srcs/docker-compose.yml down
```

### Clean Up Docker Resources

```bash
make clean
# Runs: docker system prune -a --force
```

### Full Purge (Including Data)

```bash
make fclean
# Removes:
# - Containers
# - Images
# - Volumes (db_data, wp_data, portainer_data)
# - Host data directories at ~/data/
```

### Rebuild Everything

```bash
make re
# Runs: make fclean && make up
```

---

## Security Considerations

### Credentials

- All credentials in `.env` file (excluded from git)
- No passwords in Dockerfiles
- Use environment variables for all configuration
- Use strong passwords in production

### Network

- Use custom bridge network (inception_network)
- No `network: host` (forbidden)
- No `--link` (deprecated)
- Port 443 only for NGINX (no port 80)

### Images

- Build from penultimate stable Debian (bookworm)
- No ready-made images from DockerHub (except base OS)
- One Dockerfile per service
- No forbidden patterns (tail -f, sleep infinity)

---

## Resources

### Official Documentation

- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- WordPress CLI: https://developer.wordpress.org/cli/commands/
- MariaDB: https://mariadb.com/kb/en/
- NGINX: https://nginx.org/en/docs/

### Additional Reading

- Docker Best Practices: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- Docker Networking: https://docs.docker.com/network/
- Docker Volumes: https://docs.docker.com/storage/volumes/