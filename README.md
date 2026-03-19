_This project has been created as part of the 42 curriculum by smarin-a._

# Inception

## Description
Inception is a system administration project focused on containerization with Docker and service orchestration with Docker Compose.

The goal is to build a small, production-like web stack where each service runs in its own container and communicates through a private Docker network:
- NGINX (TLS termination and reverse proxy)
- WordPress + PHP-FPM (application layer)
- MariaDB (database)

The project emphasizes reproducibility, service isolation, persistent data, and secure secret handling.

## Project Architecture And Design Choices
### Docker Use In This Project
This project uses Docker to package every service with its own dependencies and startup logic.

Main sources included in the repository:
- [Makefile](Makefile): entry points to build, start, stop, clean, and rebuild the stack.
- [srcs/docker-compose.yml](srcs/docker-compose.yml): service orchestration, networks, volumes, secrets, and dependencies.
- [srcs/requirements/mariadb/Dockerfile](srcs/requirements/mariadb/Dockerfile): MariaDB image build.
- [srcs/requirements/mariadb/tools/init_db.sh](srcs/requirements/mariadb/tools/init_db.sh): DB initialization (users, database, grants).
- [srcs/requirements/nginx/Dockerfile](srcs/requirements/nginx/Dockerfile): NGINX + TLS image build.
- [srcs/requirements/nginx/conf/nginx.conf](srcs/requirements/nginx/conf/nginx.conf): HTTPS server and FastCGI routing to WordPress.
- [srcs/requirements/wordpress/Dockerfile](srcs/requirements/wordpress/Dockerfile): PHP-FPM + WP-CLI image build.
- [srcs/requirements/wordpress/tools/setup_wp.sh](srcs/requirements/wordpress/tools/setup_wp.sh): WordPress auto-configuration and first-run setup.
- [srcs/.env](srcs/.env): non-sensitive configuration values.
- [secrets/](secrets/): sensitive credentials injected as Docker secrets.

Main design choices:
- One process domain per container, with clear responsibilities per service.
- Internal communication on a custom bridge network (`inception`) only.
- Persistent data stored through Docker volumes backed by host paths in [data/](data/).
- Credentials passed through Docker secrets files, not hardcoded in images.
- HTTPS exposed on port 443 at NGINX as the only public entrypoint.

### Concept Comparisons
#### Virtual Machines vs Docker
- Virtual Machines virtualize full operating systems and require more resources.
- Docker containers share the host kernel, start faster, and are lighter.
- This project uses Docker for faster iteration, simpler reproducibility, and easier service composition.

#### Secrets vs Environment Variables
- Environment variables are convenient for non-sensitive config (domain, usernames, titles).
- Secrets are better for passwords because they are mounted at runtime as files and reduce exposure in logs/config dumps.
- This project uses both: [.env](srcs/.env) for general config and [secrets/](secrets/) for passwords.

#### Docker Network vs Host Network
- Host network mode bypasses network isolation and can cause port conflicts.
- A Docker bridge network isolates services and provides internal DNS between containers.
- This project uses a dedicated bridge network (`inception`) for controlled, private service communication.

#### Docker Volumes vs Bind Mounts
- Docker volumes are managed by Docker and are portable/safer for persistent state.
- Bind mounts map explicit host paths and are practical for local inspection.
- This project defines named volumes in Compose and maps them to host paths (`../data/...`) to keep persistence while allowing direct local access.

## Instructions
### Prerequisites
- Docker Engine installed.
- Docker Compose plugin available (`docker compose`).
- `make` installed.

### Initial Setup
1. Clone the repository and move into it.
2. Ensure the required secret files exist in [secrets/](secrets/):
   - `db_password.txt`
   - `db_root_password.txt`
   - `wp_admin_password.txt`
   - `wp_user_password.txt`
3. Review [srcs/.env](srcs/.env) and set cluster values before deployment:
   - `DOMAIN_NAME=smarin-a.42.fr`
   - `LOGIN=smarin-a`
   - Keep WordPress user/admin metadata aligned with your cluster identity.

### Build And Run
From repository root:

```bash
make up
```

Then open:
- `https://smarin-a.42.fr` (42 VM cluster setup)

Optional local testing:
- `https://localhost`

### Useful Commands
```bash
make down     # stop containers
make stop     # stop services without removal
make start    # restart stopped services
make build    # rebuild images
make clean    # remove containers + volumes + orphans
make fclean   # deep cleanup (images, network, local data folders)
make re       # full rebuild (fclean + up)
```

### Notes
- The stack exposes only HTTPS on port `443` through NGINX.
- WordPress and MariaDB data are persisted in [data/wordpress](data/wordpress) and [data/mariadb](data/mariadb).

## Resources
Classic references used for this topic:
- Docker documentation: https://docs.docker.com/
- Docker Compose specification: https://docs.docker.com/compose/
- NGINX docs: https://nginx.org/en/docs/
- MariaDB docs: https://mariadb.com/kb/en/documentation/
- WordPress docs: https://wordpress.org/documentation/
- WP-CLI docs: https://developer.wordpress.org/cli/commands/

### AI Usage Disclosure
AI assistance was used for:
- Drafting and structuring this README.
- Refining technical comparisons (VM vs Docker, secrets vs env vars, networking, storage).
- Language polishing and consistency checks.

AI was not used to replace understanding of the project architecture; implementation details were documented from the repository source files.
