# USER_DOC

## 1. Services Provided By The Stack
The platform runs 3 Docker services:
- `nginx`: HTTPS entry point on port `443`.
- `wordpress`: web application layer (WordPress) with `php-fpm`.
- `mariadb`: database where WordPress stores its data.

General flow:
- Your browser reaches `nginx`.
- `nginx` forwards PHP requests to `wordpress`.
- `wordpress` reads/writes data in `mariadb`.

## 2. Start And Stop The Project
From the repository root:

```bash
make up
```
Builds images and starts containers.

```bash
make down
```
Stops and removes the stack containers.

Useful commands:

```bash
make stop   # stop services without removing them
make start  # restart stopped services
make re     # full cleanup + rebuild
```

## 3. Access The Website And Admin Panel
With the stack running:
- Website: `https://smarin-a.42.fr`
- WordPress admin panel: `https://smarin-a.42.fr/wp-admin`

Notes:
- In VM cluster deployment, use your 42 domain configured in [srcs/.env](srcs/.env).
- For local testing, a self-signed certificate may trigger a browser security warning.
- Admin username/password are created automatically on first startup (see credentials section).

## 4. Credentials: Location And Management
The project separates general configuration and secrets:

- General configuration (non-sensitive): [srcs/.env](srcs/.env)
  - example: `DOMAIN_NAME=smarin-a.42.fr`, `LOGIN=smarin-a`, `WP_TITLE`, `WP_ADMIN_USER`, `WP_USER`, emails, etc.
- Passwords (sensitive): [secrets/](secrets/)
  - `db_password.txt`
  - `db_root_password.txt`
  - `wp_admin_password.txt`
  - `wp_user_password.txt`

To change credentials:
1. Edit files inside [secrets/](secrets/).
2. If you need a full WordPress/DB reconfiguration, run:

```bash
make re
```

## 5. Check That Services Are Running Correctly
### Container status
```bash
docker compose -f srcs/docker-compose.yml ps
```
You should see `mariadb`, `wordpress`, and `nginx` with `Up` status.

### Logs
```bash
docker compose -f srcs/docker-compose.yml logs -f
```
Use `Ctrl+C` to exit.

### Quick functional verification
- Open `https://smarin-a.42.fr` and confirm WordPress loads.
- Open `https://smarin-a.42.fr/wp-admin` and log in with the admin user.

## 6. Persistent Data
Even if you stop the stack, data is kept in:
- [data/mariadb](data/mariadb)
- [data/wordpress](data/wordpress)

Only `make fclean` also removes this local data and recreates empty folders.

## 7. Accessing the virtual machine (SSH)

To perform the review you can connect to the virtual machine via SSH. Make sure the VM is running and that SSH port forwarding (2222) is enabled.

Connect with the following command:

```bash
ssh smarin-a@localhost -p 2222
```

Quick notes:
- User: `smarin-a`
- Host: `localhost`
- Port: `2222`
- If the connection fails, check that the VM is started and that port 2222 is listening on the host machine.

We will expand this section with steps for copying files, inspecting logs and other instructions needed for the review.

To copy the repository contents from your host into the VM, you can use scp. Example (from your host machine):

```bash
scp -P 2222 -r ~/Desktop/inception-42/* smarin-a@localhost:/home/smarin-a/Desktop/inception
```

Notes:
- `-P 2222` specifies the SSH port forwarded to the VM.
- `-r` copies directories recursively.
- The command copies all files from `~/Desktop/inception-42/` on your host into `~/inception/` on the VM. Adjust paths as needed.
