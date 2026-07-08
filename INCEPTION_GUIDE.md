# Inception — Complete End-to-End Guide (42 School)

> **Role of this document:** Your software engineering course material. Read it top-to-bottom once, then use it as a reference while you implement each file in the skeleton.

---

## Table of Contents

1. [What you are building](#1-what-you-are-building)
2. [Core definitions](#2-core-definitions)
3. [Architecture and data flow](#3-architecture-and-data-flow)
4. [Project organization](#4-project-organization)
5. [Phase 0 — VM and host preparation](#5-phase-0--vm-and-host-preparation)
6. [Phase 1 — Secrets and environment](#6-phase-1--secrets-and-environment)
7. [Phase 2 — MariaDB container](#7-phase-2--mariadb-container)
8. [Phase 3 — WordPress + PHP-FPM container](#8-phase-3--wordpress--php-fpm-container)
9. [Phase 4 — NGINX reverse proxy + TLS](#9-phase-4--nginx-reverse-proxy--tls)
10. [Phase 5 — Docker Compose orchestration](#10-phase-5--docker-compose-orchestration)
11. [Phase 6 — Makefile automation](#11-phase-6--makefile-automation)
12. [Phase 7 — Documentation and validation](#12-phase-7--documentation-and-validation)
13. [Common failure modes](#13-common-failure-modes)
14. [Defense preparation](#14-defense-preparation)
15. [Bonus services (optional)](#15-bonus-services-optional)

---

## 1. What you are building

**Inception** is a **system administration** project, not a web development project. Your deliverable is a **small, production-like infrastructure** running inside a **Virtual Machine**, orchestrated by **Docker Compose**.

### Mandatory services

| Service    | Container role                         | Exposed to host? |
|-----------|-----------------------------------------|------------------|
| `nginx`   | HTTPS entry point (TLS 1.2/1.3), reverse proxy to PHP-FPM | **Yes — port 443 only** |
| `wordpress` | WordPress files + `php-fpm` (no NGINX here) | No |
| `mariadb` | Database server for WordPress           | No |

### Hard constraints (non-negotiable)

- Custom **Dockerfile per service** — no pulling ready-made WordPress/MariaDB/NGINX images.
- Base image: **penultimate stable** Alpine **or** Debian only.
- **Named volumes** for DB + WordPress files, stored under `/home/<login>/data` on the host.
- **No bind mounts** for those two volumes.
- **No** `network: host`, **no** `links:`.
- **No** `tail -f`, `sleep infinity`, `while true`, or infinite loops as PID 1.
- **No** passwords in Dockerfiles; use `.env` + **Docker secrets**.
- Domain: `<login>.42.fr` → your VM IP (edit `/etc/hosts` during dev).
- WordPress: **2 users**, one admin whose username **cannot** contain `admin` or `administrator`.
- `restart` policy so containers recover from crashes.

---

## 2. Core definitions

### Virtual Machine (VM)

A full guest OS (CPU, RAM, disk) running on your host. 42 requires Inception on a VM so you practice real sysadmin: networking, firewall, DNS-like setup, persistent disks.

### Docker

A platform to **package** an application and its dependencies into an **image**, then run it as an **isolated process** called a **container**.

- **Image** = read-only template (layers).
- **Container** = running instance of an image.
- **Dockerfile** = recipe to build an image.
- **Docker Compose** = YAML file describing multi-container apps (services, networks, volumes).

### Container vs Virtual Machine

| Aspect | VM | Container |
|--------|----|-----------|
| Isolation | Full OS per VM | Shared host kernel, isolated namespaces |
| Boot time | Minutes | Seconds |
| Size | GBs | MBs (typically) |
| Use case | Different OS kernels | Same kernel, packaged apps |

**Takeaway:** A container is **not** a mini-VM. Do not run `systemd` or hacky keep-alive loops; run the **actual daemon** as PID 1 (or use a proper init wrapper).

### PID 1 in containers

The first process in a container must:

1. **Start** the main service (e.g. `nginx`, `php-fpm`, `mysqld`).
2. **Reap zombie processes** (optional but best practice — `tini` or `dumb-init` on Alpine/Debian).

Forbidden pattern:

```dockerfile
CMD ["tail", "-f", "/dev/null"]  # WRONG — subject forbids this
```

Correct pattern:

```dockerfile
CMD ["nginx", "-g", "daemon off;"]  # nginx stays foreground
```

### Reverse proxy

NGINX receives HTTPS from the browser, terminates TLS, and forwards HTTP to `wordpress:9000` (PHP-FPM). The database is reached only by WordPress over the internal Docker network.

### PHP-FPM

FastCGI Process Manager — runs PHP outside of NGINX. WordPress container runs **php-fpm**; NGINX passes `.php` requests via FastCGI.

### MariaDB

MySQL-compatible database. WordPress stores posts, users, options in MariaDB.

### TLS (SSL)

Encrypts traffic between browser and NGINX. Subject requires **TLSv1.2 or TLSv1.3 only**. You need a certificate — for local/dev, a **self-signed** cert is fine.

### Named volume

Docker-managed storage. Data lives on the host at a path Docker controls. You configure the host path via Compose `driver_opts` → `/home/<login>/data/...`.

### Bind mount

Maps a host directory directly into a container. **Forbidden** for the two mandatory WordPress/MariaDB data volumes.

### Environment variables vs Docker secrets

| Mechanism | Best for | Risk |
|-----------|----------|------|
| `.env` file | Non-secret config (domain, DB name, usernames) | Can leak if committed |
| Docker secrets | Passwords, root passwords | Files in `secrets/`, mounted read-only in containers |

**Rule:** Never commit real passwords. Use `.gitignore` + secrets files created locally on the VM.

### Docker network

A virtual L2 network. Containers get DNS names = service names (`mariadb`, `wordpress`, `nginx`). Only `nginx` publishes port 443 to the host.

---

## 3. Architecture and data flow

```
                    Internet / Browser
                           |
                    https://login.42.fr:443
                           |
                    +-------------+
                    |    nginx    |  TLS termination, static files optional
                    +------+------+
                           | FastCGI :9000
                    +------v------+
                    |  wordpress  |  php-fpm, WP files in volume
                    +------+------+
                           | TCP :3306
                    +------v------+
                    |   mariadb   |  data in volume
                    +-------------+

Volumes (named, on host):
  /home/<login>/data/mariadb   → database files
  /home/<login>/data/wordpress → /var/www/html (or similar)
```

### Request flow (step by step)

1. User opens `https://<login>.42.fr`.
2. DNS/hosts resolves to VM IP.
3. NGINX accepts TLS on 443, serves or proxies to PHP-FPM.
4. PHP runs WordPress, which queries `mariadb:3306`.
5. Response returns through NGINX to the browser.

---

## 4. Project organization

```
inception/
├── Makefile                 # Entry point: build, up, down, clean
├── README.md                # Project overview (42 required sections)
├── USER_DOC.md              # For operators / end users
├── DEV_DOC.md               # For developers setting up from scratch
├── INCEPTION_GUIDE.md       # This guide (optional in repo, keep for yourself)
├── .gitignore
├── secrets/                 # NOT in git — passwords only on VM
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt      # optional aggregate
└── srcs/
    ├── .env                 # Non-secret variables (DOMAIN_NAME, users, DB name)
    ├── .env.example         # Template committed to git
    ├── docker-compose.yml   # Services, networks, volumes, secrets
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/        # Custom cnf, init scripts
        │   └── tools/       # Entrypoint scripts
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/        # nginx.conf, site config, ssl/
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/        # php-fpm pool, wp-config snippets
        │   └── tools/       # wp-cli install script
        └── bonus/           # Only if doing bonus
            ├── redis/
            ├── ftp/
            └── ...
```

### Design principle: separation of concerns

- **One service = one container = one Dockerfile = one image name matching service name.**
- **Configuration** in `conf/` and `tools/`, not hardcoded in Dockerfile when avoidable.
- **Orchestration** only in `docker-compose.yml`.
- **Automation** only in `Makefile`.

---

## 5. Phase 0 — VM and host preparation

### 5.1 Create data directories

```bash
mkdir -p /home/<login>/data/mariadb
mkdir -p /home/<login>/data/wordpress
```

Compose will map named volumes to these paths using `driver: local` and `driver_opts.device`.

### 5.2 Domain resolution

Edit `/etc/hosts` on the machine **from which you browse** (often the VM itself):

```
<VM_IP>   <login>.42.fr
```

Get VM IP: `ip a` or `hostname -I`.

### 5.3 Install Docker on VM

Follow official Docker Engine + Docker Compose plugin docs for your distro. Verify:

```bash
docker --version
docker compose version
```

### 5.4 Firewall

Ensure port **443** is open on the VM if a firewall is enabled.

---

## 6. Phase 1 — Secrets and environment

### 6.1 Create `srcs/.env`

Use **non-secret** values only:

- `DOMAIN_NAME=<login>.42.fr`
- `MYSQL_DATABASE=wordpress`
- `MYSQL_USER=wpuser` (example)
- `WORDPRESS_DB_HOST=mariadb`
- Admin display name, etc.

### 6.2 Create `secrets/*.txt`

One password per line, no quotes, no trailing newline issues:

```bash
openssl rand -base64 32 > secrets/db_password.txt
openssl rand -base64 32 > secrets/db_root_password.txt
chmod 600 secrets/*.txt
```

### 6.3 WordPress admin username rule

Choose something like `supervisor`, `editor42`, `siteowner` — **not** `admin`, `admin-1`, `Administrator`.

---

## 7. Phase 2 — MariaDB container

### Goals

- Image built from Debian/Alpine penultimate stable.
- `mariadb` service runs `mysqld` as PID 1.
- Initialize DB and user on **first start** (entrypoint script).
- Persist data in named volume.

### Techniques

1. **Dockerfile:** install `mariadb-server`, copy `conf/` and `tools/entrypoint.sh`.
2. **Entrypoint:** read secrets from `/run/secrets/`, export `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, run official init or `mysql_install_db`, then `exec mysqld`.
3. **Healthcheck (recommended):** `mysqladmin ping -h localhost`.

### Order of startup

MariaDB must be **healthy** before WordPress installs. Use `depends_on` with `condition: service_healthy` in Compose v2.

---

## 8. Phase 3 — WordPress + PHP-FPM container

### Goals

- Install WordPress (download tarball or `wp-cli`).
- Configure `php-fpm` to listen on `9000` (default).
- **No NGINX** in this container.
- Auto-configure `wp-config.php` from env + secrets.
- Create **2 users** (one admin) via `wp-cli` in entrypoint **once**.

### Techniques

1. **Dockerfile:** `php-fpm`, extensions (`mysqli`, `gd`, `curl`, etc.), WordPress files under `/var/www/html`.
2. **Volume:** mount named volume at `/var/www/html` so uploads/themes persist.
3. **Entrypoint:** wait for DB → copy `wp-config` if missing → `wp core install` → `wp user create` for second user.
4. **CMD:** `php-fpm -F` (foreground).

### wp-cli

Simplifies install and user creation. Install in Dockerfile or download in entrypoint.

---

## 9. Phase 4 — NGINX reverse proxy + TLS

### Goals

- Only entry point; **port 443** published.
- TLS 1.2/1.3 only.
- Proxy PHP to `wordpress:9000`.
- Serve `login.42.fr` as `server_name`.

### TLS certificate generation (self-signed example)

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout conf/ssl/nginx.key \
  -out conf/ssl/nginx.crt \
  -subj "/CN=<login>.42.fr"
```

**Do not commit private keys** if policy forbids — generate at build time in Dockerfile or mount from secrets.

### NGINX config essentials

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
fastcgi_pass wordpress:9000;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
```

### CMD

```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

---

## 10. Phase 5 — Docker Compose orchestration

### Service checklist

```yaml
services:
  mariadb:
    build: ./requirements/mariadb
    image: mariadb          # name must match service
    volumes: [mariadb_data:/var/lib/mysql]
    networks: [inception]
    secrets: [...]
    restart: unless-stopped

  wordpress:
    build: ./requirements/wordpress
    image: wordpress
    volumes: [wordpress_data:/var/www/html]
    depends_on: { mariadb: { condition: service_healthy } }
    networks: [inception]
    env_file: .env
    secrets: [...]
    restart: unless-stopped

  nginx:
    build: ./requirements/nginx
    image: nginx
    ports: ["443:443"]
    depends_on: [wordpress]
    networks: [inception]
    restart: unless-stopped

networks:
  inception:
    driver: bridge

volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/<login>/data/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/<login>/data/wordpress
```

> **Note:** Using `local` driver with `device` under `/home/<login>/data` satisfies "named volumes stored on host" while avoiding bind mounts **in the service definition** — this is the standard 42 Inception pattern. Confirm with your eval sheet.

### Secrets in Compose

```yaml
secrets:
  db_password:
    file: ../secrets/db_password.txt
```

Reference in service: `secrets: [db_password]` → mounted at `/run/secrets/db_password`.

---

## 11. Phase 6 — Makefile automation

Typical targets:

| Target | Action |
|--------|--------|
| `all` / `build` | `docker compose -f srcs/docker-compose.yml build` |
| `up` | `docker compose ... up -d` |
| `down` | `docker compose ... down` |
| `clean` | down + remove volumes/images (destructive) |
| `re` | clean + build + up |
| `logs` | follow logs |

Always call compose from project root with explicit `-f srcs/docker-compose.yml`.

---

## 12. Phase 7 — Documentation and validation

### README.md (42 mandatory)

- First line italic: *This project has been created as part of the 42 curriculum by `<login>`.*
- Sections: Description, Instructions, Resources, Project description.
- Comparisons: VM vs Docker, Secrets vs Env, Docker Network vs Host, Volumes vs Bind Mounts.
- How you used AI.

### USER_DOC.md

For someone who only operates the stack: start/stop, URL, wp-admin, credentials location, health checks.

### DEV_DOC.md

For a developer cloning on a fresh VM: prerequisites, secrets setup, build commands, volume paths, troubleshooting.

### Validation checklist

- [ ] `make` builds without pulling forbidden images
- [ ] `https://<login>.42.fr` loads WordPress
- [ ] `docker ps` shows 3 containers restarting policy
- [ ] Only 443 exposed on host
- [ ] TLS 1.2+ only (test with `openssl s_client -connect <login>.42.fr:443 -tls1_1` → should fail)
- [ ] Data persists after `docker compose down` and `up`
- [ ] Two WP users exist; admin name has no "admin"/"administrator"
- [ ] No credentials in git history
- [ ] No `latest` tag in Dockerfiles (use specific version)

---

## 13. Common failure modes

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| 502 Bad Gateway | php-fpm not listening / wrong `fastcgi_pass` | Check `wordpress:9000`, pool `listen` |
| Database connection error | WP starts before DB ready | `depends_on` + healthcheck |
| Permission denied on uploads | Volume UID mismatch | `chown www-data` in entrypoint |
| Certificate warning | Self-signed cert | Expected; proceed in browser |
| Empty page / 403 | `root` path wrong in nginx | Align with `/var/www/html` |
| Container exits immediately | Wrong CMD, daemon mode | Foreground process as PID 1 |
| Eval fails on volumes | Data not under `/home/login/data` | Fix `driver_opts.device` |

---

## 14. Defense preparation

Evaluators may ask you to:

- Change an env variable and rebuild.
- Add a line to nginx or a user via wp-cli.
- Explain FastCGI vs proxy_pass.
- Show where data persists on the host.
- Modify TLS or restart policy.

**Prepare by understanding every line** of your Dockerfiles, entrypoints, and compose file — not just running `make`.

### Questions you must answer fluently

1. Why is NGINX separate from WordPress?
2. What happens on first boot vs second boot?
3. How do secrets reach MariaDB without being in the image?
4. Difference between `docker compose down` and `down -v`?
5. Why forbidden to use `network: host`?

---

## 15. Bonus services (optional)

Only if mandatory part is **perfect**:

| Bonus | Hint |
|-------|------|
| Redis | Cache for WordPress — `redis` container, WP plugin or object cache drop-in |
| FTP | `vsftpd` pointing at wordpress volume |
| Static site | Separate container + NGINX server block or second port |
| Adminer | PHP DB UI — **do not expose DB port**; proxy via NGINX if needed |

Each bonus = own Dockerfile, own container, own volume if needed.

---

## Suggested implementation order

```
Week flow (self-paced):
  1. VM + Docker + /home/<login>/data
  2. mariadb Dockerfile + entrypoint → test alone
  3. wordpress Dockerfile + entrypoint → test with mariadb
  4. nginx Dockerfile + TLS → full stack
  5. Makefile + polish
  6. README / USER_DOC / DEV_DOC
  7. Bonus (if time)
```

---

## Essential references

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [NGINX HTTPS](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [PHP-FPM](https://www.php.net/manual/en/install.fpm.php)
- [WordPress wp-cli](https://developer.wordpress.org/cli/commands/)
- [MariaDB Docker patterns](https://mariadb.com/kb/en/docker-and-mariadb/)

---

*You own this infrastructure once you can draw the diagram from memory, explain every volume mount, and rebuild it on a blank VM in under an hour.*
