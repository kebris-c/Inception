# Developer Documentation — Inception

Audience: **developer** setting up the project from scratch on a new VM.

---

## Prerequisites

- 42 Linux VM (project must run on VM)
- Docker Engine + Docker Compose v2 plugin
- `make`, `git`, `openssl`
- User in the `docker` group
- Port **443** available on the VM

### Host directories

```bash
make setup
```

This creates:

- `/home/kebris-c/data/mariadb`
- `/home/kebris-c/data/wordpress`
- `srcs/.env` from template
- `secrets/*.txt` with random passwords

Volume paths are configured in `srcs/docker-compose.yml` under `volumes.mariadb_data` and `volumes.wordpress_data`.

---

## Repository layout

```
Makefile
README.md
USER_DOC.md
DEV_DOC.md
secrets/              → local password files (gitignored)
srcs/
  .env                → from .env.example (gitignored)
  docker-compose.yml
  requirements/
    mariadb/
    wordpress/
    nginx/
    bonus/            → optional, not wired in mandatory stack
```

---

## Configuration from scratch

### 1. Clone and enter repo

```bash
git clone <your-repo>
cd Inception
```

### 2. First-time setup

```bash
make setup
```

Edit `srcs/.env` if you need to change domain, emails, or usernames.

### 3. Domain resolution

```bash
echo "<VM_IP>  kebris-c.42.fr" | sudo tee -a /etc/hosts
```

Replace `<VM_IP>` with the output of `hostname -I`.

---

## Build and launch

```bash
make build    # Build all images from Dockerfiles
make up       # Start stack detached
make logs     # Debug
make down     # Stop (keeps volumes)
make re       # Full rebuild — removes volumes and images
```

Compose file: `srcs/docker-compose.yml` (invoked by Makefile).

---

## Managing containers and volumes

| Task | Command |
|------|---------|
| List containers | `make ps` |
| Logs one service | `docker compose -f srcs/docker-compose.yml logs -f nginx` |
| Shell in container | `docker exec -it wordpress bash` |
| Inspect volume | `docker volume inspect inception_wordpress_data` |

### Data persistence

| Data | Host path |
|------|-----------|
| MariaDB files | `/home/kebris-c/data/mariadb` |
| WordPress files | `/home/kebris-c/data/wordpress` |

Data survives `make down`. `make clean` or `make re` removes volumes and **deletes** data.

---

## Implementation checklist

- [x] MariaDB Dockerfile + entrypoint initializes DB and user
- [x] WordPress Dockerfile + entrypoint installs WP and 2 users
- [x] NGINX Dockerfile + TLS 1.2/1.3 + FastCGI to wordpress:9000
- [x] Compose: network, volumes, secrets, restart, depends_on + healthcheck
- [x] Makefile targets work
- [x] No passwords in git or Dockerfiles
- [x] Admin username does not contain `admin` / `administrator`

---

## Debugging tips

1. **MariaDB alone** — temporarily comment out wordpress/nginx in compose, run `make up`, check healthcheck.
2. **WordPress logs** — DB connection errors → verify secrets and `.env` host/user/database names.
3. **NGINX 502** — php-fpm must listen on `9000`; check `fastcgi_pass wordpress:9000`.
4. **Permission errors** — entrypoint runs `chown www-data:www-data` on `/var/www/html`.
5. **TLS test** — `openssl s_client -connect kebris-c.42.fr:443 -tls1_1` should fail; `-tls1_2` should succeed.

---

## Subject constraints (quick reference)

- Custom Dockerfiles only (no prebuilt WP/nginx/mariadb images)
- Image name == service name
- No `network: host`, no `links:`
- No `tail -f` / `bash` / `sleep infinity` / `while true` as PID 1
- Named volumes under `/home/kebris-c/data`
- Port 443 only for mandatory entry point
- `.env` mandatory; Docker secrets strongly recommended for passwords

---

## AI usage (developer note)

AI was used for guidelines, templates, and conceptual explanations during early scaffolding. The final implementation should be rebuilt, tested, and understood manually before defense. Document your own verification steps here as you work through the project.
