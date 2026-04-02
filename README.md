_This project has been created as part of the 42 curriculum by kgriset_

## Description

Inception is a Docker-based infrastructure project that demonstrates system administration skills by setting up a complete WordPress hosting environment using multiple containerized services.

### Project Goal

The goal of this project is to:
- Virtualize a complete infrastructure using Docker
- Set up a production-ready WordPress deployment
- Implement proper security with SSL/TLS
- Manage persistent data with Docker volumes
- Provide bonus services for enhanced functionality

### Services Overview

| Service | Purpose | Port |
|---------|---------|------|
| **NGINX** | Reverse proxy with SSL/TLS termination | 443 |
| **WordPress** | Content Management System with PHP-FPM | 9000 (internal) |
| **MariaDB** | Database server | 3306 (internal) |
| **Redis** | Object cache for WordPress performance | 6379 (internal) |
| **FTP** | File transfer server for WordPress files | 21, 40000-40005 |
| **Adminer** | Database management web interface | 8080 |
| **Portainer** | Docker container management UI | 9000 |
| **Static Site** | Simple Python-based static website | 8081 |

---

## Instructions

### Prerequisites

- Docker installed (version 20.x or higher)
- Docker Compose installed (version 2.x or higher)
- Virtual Machine (project must run on a VM)

### Installation & Setup

1. **Clone the repository**
   ```bash
   cd ~
   git clone https://github.com/iluvshiwoon/inception.git inception
   cd inception
   ```

2. **Configure environment variables**
   ```bash
   cd srcs
   # Edit .env file with your credentials
   # The .env file is excluded from git for security
   ```

3. **Create data directories**
   ```bash
   mkdir -p ~/data/wordpress ~/data/mariadb ~/data/portainer
   chmod -R 777 ~/data
   ```

### Running the Project

```bash
# Start all services
make up

# View logs
make logs

# Stop all services
make down

# Stop containers (keep data)
make stop

# Resume stopped containers
make start

# Clean up Docker resources
make clean

# Full purge (including data volumes)
make fclean
```

### Accessing Services

- **WordPress**: https://kgriset.42.fr
- **WordPress Admin**: https://kgriset.42.fr/wp-admin
- **Adminer**: https://kgriset.42.fr/adminer
- **Static Site**: https://kgriset.42.fr/static
- **Portainer**: http://localhost:9000
- **FTP**: localhost:21

---

## Project Description

### Docker & Sources

This project uses **custom Dockerfiles** for each service, built from the **penultimate stable version of Debian (Bookworm)**. All images are built locally using Docker Compose - no pre-built images from DockerHub are used (except for the base Debian OS).

The project demonstrates:
- Writing Dockerfiles from scratch
- Containerizing multiple services
- Managing inter-container communication
- Implementing persistent storage
- Configuring SSL/TLS security

### Design Choices

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|-----------------|-------------------|
| **Architecture** | Emulates complete hardware, runs full OS | Shares host OS kernel, isolated user spaces |
| **Resource Usage** | Heavy (GBs of storage, full OS overhead) | Light (MBs, shared kernel) |
| **Startup Time** | Minutes (boot full OS) | Seconds (start process) |
| **Isolation** | Complete isolation (separate kernel) | Process-level isolation |
| **Use Case** | Running multiple different OSes | Containerizing applications |

In this project, Docker is used because:
- Faster deployment and testing
- Consistent environment across runs
- Easy to scale and replicate
- Lower resource consumption on the VM

#### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|----------------|
| **Storage** | Plain text in .env file | Stored in Docker Swarm/Secret store |
| **Access** | Available to all containers | Only accessible to authorized services |
| **Management** | Simple key-value pairs | More complex, requires Swarm mode |
| **Security** | Basic (excluded from git) | More secure at runtime |

This project uses **environment variables** because:
- Docker Compose provides built-in env_file support
- Simpler to implement without Swarm mode
- Sufficient security when .env is excluded from git
- All credentials can be managed in one file

#### Docker Network vs Host Network

| Aspect | Docker Network (Bridge) | Host Network |
|--------|------------------------|--------------|
| **Isolation** | Isolated from host network | Shares host network namespace |
| **Port Mapping** | Required to expose ports | No mapping needed |
| **Security** | Better isolation (container-to-container only) | Less secure |
| **Flexibility** | Custom networks allow service discovery | Limited control |

This project uses **Docker Network (bridge)** because:
- Provides proper isolation between services
- Allows containers to communicate by service name
- Prevents direct access from host (except exposed ports)
- More secure than host network mode

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|-------------|
| **Location** | Managed by Docker (/var/lib/docker) | Host filesystem path |
| **Persistence** | Survives container removal | Tied to host path |
| **Portability** | Works across Docker hosts | Host-dependent |
| **Use Case** | Persistent data (databases) | Development (code changes) |

This project uses **Docker named volumes with bind driver** because:
- Volumes persist data across container restarts
- Data stored at `/home/kgriset/data/` as required by the subject
- Bind driver allows specifying exact host path
- Survives VM reboots (data persists on host filesystem)

---

## Bonus Services

This project implements 5 bonus services as allowed by the subject:

1. **Redis Cache** - Object caching for WordPress to improve performance
2. **FTP Server** - vsftpd container for managing WordPress files
3. **Static Website** - Python-based HTTP server with static HTML
4. **Adminer** - Web-based database management interface
5. **Portainer** - Docker container management dashboard

Each bonus service has its own Dockerfile and runs in an isolated container.

---

## Resources

### Documentation & References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WordPress CLI Commands](https://developer.wordpress.org/cli/commands/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [Debian Bookworm Documentation](https://www.debian.org/releases/bookworm/)

### AI Usage

AI was used in the following ways for this project:

1. **Documentation Generation** - Used to structure and format the README.md, USER_DOC.md, and DEV_DOC.md files, ensuring all required sections from the subject were properly covered.

2. **Docker Configuration Review** - AI-assisted in reviewing docker-compose.yml configurations to verify compliance with project requirements (no network:host, proper volumes, correct ports).

3. **Code Explanation** - Used to generate clear explanations for the comparison sections (VMs vs Docker, Secrets vs Environment Variables, etc.) required in the README.

4. **Documentation Walkthrough** - AI helped format command walkthroughs in USER_DOC.md to provide step-by-step verification commands for the evaluator.

AI was not used to write core infrastructure code (Dockerfiles, docker-compose.yml, shell scripts) - these were written manually to ensure full understanding and compliance with the subject requirements.

---

## Project Structure

```
inception/
├── Makefile              # Main entry point
├── README.md             # This file
├── USER_DOC.md           # User documentation with commands
├── DEV_DOC.md            # Developer documentation
├── .gitignore            # Excludes .env from git
└── srcs/
    ├── docker-compose.yml
    ├── .env              # Environment variables (NOT committed)
    └── requirements/
        ├── nginx/        # NGINX with SSL
        ├── wordpress/    # WordPress + PHP-FPM
        ├── mariadb/      # MariaDB database
        └── bonus/
            ├── redis/    # Redis cache
            ├── ftp/      # FTP server
            ├── adminer/  # Database management
            ├── portainer/ # Docker UI
            └── static/   # Static website
```

---

## Technical Specifications

- **Base Image**: Debian Bookworm (penultimate stable)
- **TLS Version**: TLSv1.2 and TLSv1.3 only
- **Entry Point**: Port 443 only (no port 80)
- **Restart Policy**: on-failure for all containers
- **Network**: Custom bridge network (inception_network)
- **Data Volumes**: Named volumes at /home/kgriset/data/
