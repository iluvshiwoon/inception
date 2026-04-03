# Inception - User Documentation

## Quick Start

### Starting the Project

```bash
cd ~/inception
make up
```

This command:
1. Creates data directories at `/home/kgriset/data/`
2. Builds all Docker images from Dockerfiles
3. Starts all containers via Docker Compose

### Verify All Containers Running

```bash
docker ps
```

Expected output should show all 8 containers running:
- nginx
- wordpress
- mariadb
- redis
- ftp
- adminer
- portainer
- static_site

### Stopping the Project

```bash
make down      # Stop and remove containers
make stop      # Stop containers (keep data)
make start     # Resume stopped containers
make logs      # View live logs
```

---

## Verify Project Structure

### Check Directory Structure

```bash
ls -R ~/inception
```

Expected structure:
```
inception/
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       ├── mariadb/
│       └── bonus/
│           ├── redis/
│           ├── ftp/
│           ├── adminer/
│           ├── portainer/
│           └── static/
```

### Verify No Credentials in Git

```bash
cd ~/inception
git status
cat .gitignore
```

Expected: `.env` and `secrets/` should be in .gitignore

---

## Verify Docker Basics

### Check Dockerfiles Exist (One Per Service)

```bash
ls ~/inception/srcs/requirements/*/Dockerfile
ls ~/inception/srcs/requirements/bonus/*/Dockerfile
```

Expected: 8 Dockerfiles (nginx, wordpress, mariadb, redis, ftp, adminer, portainer, static_site)

### Verify Base Image (Penultimate Stable Debian)

```bash
head -1 ~/inception/srcs/requirements/nginx/Dockerfile
head -1 ~/inception/srcs/requirements/wordpress/Dockerfile
head -1 ~/inception/srcs/requirements/mariadb/Dockerfile
```

Expected: All should show `FROM debian:bookworm`

### Verify Image Names Match Services

```bash
docker images --format "{{.Repository}} {{.Tag}}" | grep srcs-
```

Expected:
- srcs-nginx
- srcs-wordpress
- srcs-mariadb
- srcs-redis
- srcs-ftp
- srcs-adminer
- srcs-portainer
- srcs-static_site

### Verify No NGINX in WordPress/MariaDB Dockerfiles

```bash
grep -i nginx ~/inception/srcs/requirements/wordpress/Dockerfile
grep -i nginx ~/inception/srcs/requirements/mariadb/Dockerfile
```

Expected: No output (NGINX should NOT be in these Dockerfiles)

---

## Verify Docker Network

### Check Network Exists

```bash
docker network ls | grep inception_network
```

Expected: inception_network with bridge driver

### Verify All Containers in Network

```bash
docker network inspect inception_network --format '{{range .Containers}}{{.Name}} {{end}}'
```

Expected: All 8 containers listed (nginx, wordpress, mariadb, redis, ftp, adminer, portainer, static_site)

---

## Verify NGINX with SSL/TLS

### Check NGINX Container Running

```bash
docker ps | grep nginx
```

Expected: nginx container running

### Verify Port 443 Only (Port 80 Should Fail)

```bash
curl -I http://localhost:80
```

Expected: Connection refused or timeout

### Verify HTTPS Works (TLS Certificate)

```bash
curl -k https://localhost
```

Expected: Should return WordPress page content (not installation wizard)

### Verify TLSv1.2/1.3 Only

```bash
docker exec nginx cat /etc/nginx/nginx.conf | grep ssl_protocols
```

Expected: Should show TLSv1.2 TLSv1.3

---

## Verify WordPress

### Check WordPress Container Running

```bash
docker ps | grep wordpress
```

Expected: wordpress container running

### Verify WordPress Installed (Not Installer)

```bash
docker exec wordpress wp --allow-root core version
```

Expected: WordPress version number (not error)

### Verify WordPress Users

```bash
docker exec wordpress wp --allow-root user list
```

Expected: Should show admin user. Admin username must NOT contain "admin" (e.g., admin, administrator, Admin-login)

### Verify Admin Username is NOT "admin"

```bash
docker exec wordpress wp --allow-root user list --format=json | grep -i admin
```

Expected: Username should be "kgriset_boss" (does not contain "admin")

### Verify Two Users in WordPress

```bash
docker exec wordpress wp --allow-root user list
```

Expected: Should show at least 2 users (1 administrator + at least 1 regular user)

### Verify WordPress Connected to Database

```bash
docker exec wordpress wp --allow-root db check
```

Expected: "Database tables OK"

---

## Verify WordPress Volume

### Check Volume Exists

```bash
docker volume ls | grep wp_data
```

Expected: wp_data volume exists

### Verify Volume at /home/kgriset/data/

```bash
docker volume inspect wp_data
```

Expected: The "Mountpoint" or "device" field should contain `/home/kgriset/data/wordpress`

### Check WordPress Files in Volume

```bash
docker exec wordpress ls -la /var/www/html | head -20
```

Expected: Should show WordPress files (wp-config.php, wp-admin/, wp-includes/, etc.)

---

## Verify MariaDB

### Check MariaDB Container Running

```bash
docker ps | grep mariadb
```

Expected: mariadb container running

### Verify MariaDB Database Exists

```bash
docker exec mariadb mysql -u root -p<SQL_ROOT_PASSWORD> -e "SHOW DATABASES;"
```

Expected: Should show wordpress_db database

### Verify Database Not Empty

```bash
docker exec mariadb mysql -u root -p<SQL_ROOT_PASSWORD> wordpress_db -e "SHOW TABLES;"
```

Expected: Should show WordPress tables (wp_posts, wp_users, wp_options, etc.)

---

## Verify MariaDB Volume

### Check Volume Exists

```bash
docker volume ls | grep db_data
```

Expected: db_data volume exists

### Verify Volume at /home/kgriset/data/

```bash
docker volume inspect db_data
```

Expected: The "Mountpoint" or "device" field should contain `/home/kgriset/data/mariadb`

---

## Verify Persistence

### Create Test Content in WordPress

```bash
docker exec wordpress wp --allow-root post create --post_title="Persistence Test" --post_content="Testing data persistence" --post_status=publish
```

### Stop All Containers

```bash
make down
# or: docker compose -f srcs/docker-compose.yml down
```

### Restart Project

```bash
make up
# or: docker compose -f srcs/docker-compose.yml up -d
```

### Verify Data Persisted

```bash
docker exec wordpress wp --allow-root post list | grep "Persistence Test"
```

Expected: Should show the "Persistence Test" post still exists

---

## Access Services

### WordPress Website

- **URL**: https://kgriset.42.fr
- **Admin Panel**: https://kgriset.42.fr/wp-admin
- **Login**: Use admin credentials from .env file (WP_ADMIN_USER, WP_ADMIN_PASSWORD)

### Add Comment as Regular User

1. Visit https://kgriset.42.fr
2. If not logged in, login as regular user (WP_USER from .env)
3. Navigate to any post
4. Submit a comment
5. Verify comment appears on the post

### Edit a Page as Admin

1. Visit https://kgriset.42.fr/wp-admin
2. Login as admin (WP_ADMIN_USER: kgriset_boss)
3. Go to Pages → All Pages
4. Click "Edit" on any page
5. Make changes and click "Update"
6. Visit the page on the public site to verify changes persist

### Edit Page via WP-CLI (Alternative)

```bash
# List pages
docker exec wordpress wp --allow-root post list --post_type=page

# Update a page
docker exec wordpress wp --allow-root post update <page_id> --post_title="Updated Page Title"
```

### Access Adminer (Database Management)

- **URL**: https://kgriset.42.fr/adminer
- **Login**: Use database credentials from .env (SQL_USER, SQL_PASSWORD)

### Access Portainer (Docker UI)

- **URL**: http://localhost:9000
- First time setup: Create admin password

### Access Static Site

- **URL**: https://kgriset.42.fr/static

### Access FTP Server

- **Host**: localhost
- **Port**: 21
- **Username**: kgriset_ftp (from .env)
- **Password**: FTP_PASSWORD (from .env)
- **Passive ports**: 40000-40005

---

## Using Bonus Services

### Redis Cache

**Purpose**: Object caching for WordPress performance - reduces database queries

**Access**: Internal (connected to WordPress)

**Demonstrate it's working**:
```bash
# Check Redis is connected to WordPress
docker exec wordpress wp --allow-root redis status

# Expected output:
# Status: Connected
# Ping: PONG
```

**Demonstrate cache is being used**:
```bash
# Check object cache is enabled
docker exec wordpress wp --allow-root option get object_cache_version

# Check Redis memory usage
docker exec redis redis-cli info memory
```

---

### FTP Server

**Purpose**: Upload/manage WordPress files remotely via FTP

**Access**: `localhost:21`

**List WordPress files via FTP**:
```bash
# List files in WordPress directory
curl ftp://localhost/ --user kgriset_ftp:$FTP_PASSWORD

# Expected: Shows wp-config.php, wp-admin/, wp-content/, etc.
```

**Upload a test file via FTP**:
```bash
# Create test file
echo "Test file from FTP" > /tmp/test_ftp.txt

# Upload via FTP
curl -T /tmp/test_ftp.txt ftp://localhost/ --user kgriset_ftp:$FTP_PASSWORD

# Verify file exists in WordPress volume
docker exec wordpress ls -la /var/www/html/test_ftp.txt
# Expected: File appears in WordPress directory
```

---

### Adminer

**Purpose**: Web-based database management interface

**Access**: https://kgriset.42.fr/adminer

**Login credentials**:
- Server: `mariadb`
- Username: `wp_user` (from .env SQL_USER)
- Password: `SQL_PASSWORD` (from .env)
- Database: `wordpress_db`

**Demonstrate it's accessible**:
```bash
# Check Adminer is serving
curl -k https://kgriset.42.fr/adminer

# Expected: HTML form with login page
```

**What you can do in Adminer**:
1. Login with WordPress database credentials
2. Browse tables: `wp_posts`, `wp_users`, `wp_options`, `wp_terms`
3. Run SQL queries: `SELECT * FROM wp_posts LIMIT 5;`
4. View and edit database records

---

### Portainer

**Purpose**: Docker container management UI - view/manage all containers

**Access**: http://localhost:9000

**First-time setup**:
1. Open http://localhost:9000
2. Create admin password
3. Select "Docker" endpoint

**Demonstrate all containers visible**:
```bash
# Verify Portainer can see all containers
curl -s http://localhost:9000/api/system/info | head -50
```

**What you can do in Portainer**:
1. View all 8 containers running
2. View container logs (click container → Logs)
3. Inspect container details (network, environment variables)
4. Restart/stop containers via UI
5. View volumes and their mount points

---

### Static Site

**Purpose**: Python-based static website served via NGINX

**Access**: https://kgriset.42.fr/static

**View static site content**:
```bash
# Get static site page content
curl -k https://kgriset.42.fr/static

# Expected: HTML page content (not 404 or redirect)
```

**Verify it's the Python server**:
```bash
# Check static_site container is responding
curl http://static_site:8081/

# Expected: Same HTML content as above
```

**What the static site demonstrates**:
- Python HTTP server running in container
- NGINX proxy_pass working correctly
- Different technology stack from WordPress (Python vs PHP)

---

## Technical Details

### Environment Variables Location

```bash
cat ~/inception/srcs/.env
```

All credentials and configuration are in the .env file. This file is excluded from git for security.

### Check Restart Policy

```bash
grep restart ~/inception/srcs/docker-compose.yml
```

Expected: All services should have `restart: on-failure`

### Check No Forbidden Patterns

```bash
grep -r "tail -f\|sleep infinity\|while true" ~/inception/srcs/requirements/*/Dockerfile
grep -r "tail -f\|sleep infinity\|while true" ~/inception/srcs/requirements/bonus/*/Dockerfile
```

Expected: No output (forbidden patterns should not exist)

### Check No network:host or --link

```bash
grep -E "network: host|links:|--link" ~/inception/srcs/docker-compose.yml
```

Expected: No output (these are forbidden)

---

## Troubleshooting

### Check Container Logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs redis
```

### Restart a Specific Service

```bash
docker compose -f srcs/docker-compose.yml restart nginx
docker compose -f srcs/docker-compose.yml restart wordpress
```

### Shell Into Container

```bash
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
```

### Rebuild a Specific Service

```bash
docker compose -f srcs/docker-compose.yml up -d --build nginx
```

### Check Disk Space

```bash
docker system df
```

### Clean Up Unused Resources

```bash
make clean  # Stop containers and clean images
make fclean # Full purge including volumes
```