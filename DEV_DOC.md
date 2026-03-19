# DEV_DOC

## 1. Setup From Scratch
### Prerequisites
- Docker Engine installed.
- Docker Compose plugin (`docker compose`) available.
- `make` installed.

### Minimum expected structure
- [Makefile](Makefile)
- [srcs/docker-compose.yml](srcs/docker-compose.yml)
- [srcs/.env](srcs/.env)
- [secrets/](secrets/)
- [srcs/requirements/](srcs/requirements/)

### Configuration
1. Review/edit variables in [srcs/.env](srcs/.env).
   - Cluster target values:
     - `DOMAIN_NAME=smarin-a.42.fr`
     - `LOGIN=smarin-a`
2. Create or update secrets in [secrets/](secrets/):
   - `db_password.txt`
   - `db_root_password.txt`
   - `wp_admin_password.txt`
   - `wp_user_password.txt`
3. Verify persistence paths in [srcs/docker-compose.yml](srcs/docker-compose.yml):
   - `../data/mariadb`
   - `../data/wordpress`

## 2. Build And Launch (Makefile + Compose)
From the repository root:

```bash
make up
```
- Runs `docker compose -f srcs/docker-compose.yml up --build`.
- Builds images (`mariadb:1.0`, `wordpress:1.0`, `nginx:1.0`) and starts services.

Stop:

```bash
make down
```

Full rebuild:

```bash
make re
```

## 3. Relevant Management Commands
### Makefile
```bash
make build    # build images
make start    # start stopped containers
make stop     # stop containers
make clean    # down -v --remove-orphans
make fclean   # clean + remove compose images/network/volumes and local data folders
```

### Direct Docker Compose
```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml exec wordpress sh
docker compose -f srcs/docker-compose.yml exec mariadb sh
```

## 4. Data Persistence And Storage Location
Persistence is defined in [srcs/docker-compose.yml](srcs/docker-compose.yml):
- Volume `mariadb_data` mounted at `/var/lib/mysql` inside the container.
- Volume `wordpress_data` mounted at `/var/www/html` inside the container.

Both use `driver: local` with bind-style `driver_opts`, pointing to:
- [data/mariadb](data/mariadb)
- [data/wordpress](data/wordpress)

Implications:
- `make down` or `make stop` does not remove data.
- `make clean` removes containers and compose volumes.
- `make fclean` also removes and recreates local folders in [data/](data/).

## 5. Where To Modify Code/Config Per Service
### MariaDB
- Build: [srcs/requirements/mariadb/Dockerfile](srcs/requirements/mariadb/Dockerfile)
- Config: [srcs/requirements/mariadb/conf/50-server.cnf](srcs/requirements/mariadb/conf/50-server.cnf)
- Init script: [srcs/requirements/mariadb/tools/init_db.sh](srcs/requirements/mariadb/tools/init_db.sh)

### WordPress
- Build: [srcs/requirements/wordpress/Dockerfile](srcs/requirements/wordpress/Dockerfile)
- Setup script: [srcs/requirements/wordpress/tools/setup_wp.sh](srcs/requirements/wordpress/tools/setup_wp.sh)

### NGINX
- Build: [srcs/requirements/nginx/Dockerfile](srcs/requirements/nginx/Dockerfile)
- Config: [srcs/requirements/nginx/conf/nginx.conf](srcs/requirements/nginx/conf/nginx.conf)

## 6. Quick Dev Environment Verification
1. `make up`
2. `docker compose -f srcs/docker-compose.yml ps`
3. Open `https://smarin-a.42.fr`
4. Check logs if there are failures:
   - `docker compose -f srcs/docker-compose.yml logs -f nginx`
   - `docker compose -f srcs/docker-compose.yml logs -f wordpress`
   - `docker compose -f srcs/docker-compose.yml logs -f mariadb`

Optional local testing URL:
- `https://localhost`
