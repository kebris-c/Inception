# Developer Documentation — Inception

Audience: **developer** setting up the project from scratch on a new VM.

---

## Prerequisites

- 42 Linux VM (project must run on VM)
- Docker Engine + Docker Compose v2 plugin
- `make`, `git`, `openssl`
- Sudo for Docker (user in `docker` group)
- Ports: **443** available on VM

### Host directories

```bash
export LOGIN=your_login
mkdir -p /home/$LOGIN/data/mariadb
mkdir -p /home/$LOGIN/data/wordpress
```

Update `device:` paths in `srcs/docker-compose.yml` volumes section.

---

## Repository layout

```
Makefile
secrets/          → local only, password files
srcs/
  .env            → from .env.example
  docker-compose.yml
  requirements/
    mariadb/
    wordpress/
    nginx/
```

See [INCEPTION_GUIDE.md](INCEPTION_GUIDE.md) for architecture and implementation order.

---

## Configuration from scratch

### 1. Clone and enter repo

```bash
git clone <your-repo>
cd inception
```

### 2. Environment file

```bash
cp srcs/.env.example srcs/.env
# Edit: DOMAIN_NAME, MYSQL_USER, WORDPRESS_ADMIN_USER, etc.
```

### 3. Secrets

```bash
openssl rand -base64 32 > secrets/db_password.txt
openssl rand -base64 32 > secrets/db_root_password.txt
chmod 600 secrets/*.txt
```

### 4. Domain

```bash
echo "<VM_IP>  your_login.42.fr" | sudo tee -a /etc/hosts
```

### 5. TLS (if generated on host)

```bash
# See srcs/requirements/nginx/conf/ssl/README.md
```

---

## Build and launch

```bash
make build    # Build all images from Dockerfiles
make up       # Start stack detached
make logs     # Debug
make down     # Stop
make re       # Full rebuild (destructive if clean removes volumes)
```

Compose file path: `srcs/docker-compose.yml` (invoked by Makefile).

---

## Managing containers and volumes

| Task | Command |
|------|---------|
| List containers | `docker compose -f srcs/docker-compose.yml ps` |
| Logs one service | `docker compose -f srcs/docker-compose.yml logs -f nginx` |
| Shell in container | `docker exec -it wordpress sh` |
| Inspect volume | `docker volume inspect <volume_name>` |

### Data persistence

| Data | Host path |
|------|-----------|
| MariaDB files | `/home/<login>/data/mariadb` |
| WordPress files | `/home/<login>/data/wordpress` |

Data survives `make down`. Removing volumes (`docker compose down -v` or `make clean`) **deletes** data.

---

## Implementation checklist

- [ ] MariaDB Dockerfile + entrypoint initializes DB and user
- [ ] WordPress Dockerfile + entrypoint installs WP and 2 users
- [ ] NGINX Dockerfile + TLS 1.2/1.3 + fastcgi to wordpress:9000
- [ ] Compose: network, volumes, secrets, restart, depends_on + healthcheck
- [ ] Makefile targets work
- [ ] No passwords in git or Dockerfiles
- [ ] Admin username does not contain `admin` / `administrator`

---

## Debugging tips

1. **Start mariadb alone** — comment out other services, verify healthcheck.
2. **wordpress logs** — DB connection errors → secrets/env/host.
3. **nginx 502** — php-fpm listen address, `fastcgi_pass wordpress:9000`.
4. **Permission errors** — `chown www-data` on volume in entrypoint.

---

## Subject constraints (quick reference)

- Custom Dockerfiles only (no prebuilt WP/nginx/mariadb images)
- Image name == service name
- No `network: host`, no `links:`
- No `tail -f` / `sleep infinity` as PID 1
- Named volumes under `/home/<login>/data`
- Port 443 only for mandatory entry point
- `.env` mandatory; secrets for passwords

---

## AI usage (document your own)

<!-- TODO: Record tools used, prompts, and verification steps for README Resources section -->
