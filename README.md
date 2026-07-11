*This project has been created as part of the 42 curriculum by `kebris-c`.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to build a small, containerized web infrastructure on a Virtual Machine using Docker Compose.

The stack runs WordPress (with PHP-FPM) behind an NGINX reverse proxy with TLS 1.2/1.3, backed by MariaDB. Each service lives in its own container, built from a custom Dockerfile on Debian bookworm-slim. Persistent data is stored in Docker named volumes mapped to `/home/kebris-c/data/` on the host.

## Instructions

### Prerequisites

- Linux VM with Docker Engine and Docker Compose v2
- Host directories (created by `make setup`):
  - `/home/kebris-c/data/mariadb`
  - `/home/kebris-c/data/wordpress`
- `/etc/hosts` entry pointing `kebris-c.42.fr` to your VM IP
- Local secret files in `secrets/` (see `secrets/README.md`)

### Setup and run

```bash
make setup    # create data dirs, .env, secrets (first time only)
make          # build images
make up       # start stack
make ps       # check status
make logs     # follow logs
make down     # stop stack
make re       # full rebuild (destructive — removes volumes)
```

Access the site at **https://kebris-c.42.fr** (accept the self-signed certificate warning).

## Project description

### Docker in this project

| Component | Role |
|-----------|------|
| `Makefile` | Entry point: builds and manages the stack via Compose |
| `srcs/docker-compose.yml` | Defines services, network, volumes, secrets |
| `srcs/requirements/mariadb/` | Custom MariaDB image + init entrypoint |
| `srcs/requirements/wordpress/` | WordPress + PHP-FPM + wp-cli entrypoint |
| `srcs/requirements/nginx/` | TLS termination + FastCGI to PHP-FPM |
| `secrets/` | Password files mounted as Docker secrets |
| `srcs/.env` | Non-secret configuration (domain, usernames, DB name) |

**Design choices:**

- **Debian bookworm-slim** as base for all three services (penultimate stable Debian).
- **wp-cli** for automated WordPress install and user creation on first boot.
- **NGINX shares the WordPress named volume** (read-only) so static files are served directly; PHP is forwarded via FastCGI to `wordpress:9000`.
- **TLS certificate** generated at container start if not present (self-signed, CN = `DOMAIN_NAME`).
- **MariaDB healthcheck** so WordPress waits until the database is ready.

### Virtual Machines vs Docker

| Virtual Machines | Docker |
|------------------|--------|
| Full guest OS with its own kernel view | Processes isolated via namespaces on the host kernel |
| Heavy (GBs), slow to boot | Lightweight (MBs), starts in seconds |
| Strong isolation, different OS possible | Same kernel; ideal for packaging apps consistently |
| Used here as the **host** where Docker runs | Used to run NGINX, WordPress, MariaDB as separate services |

### Secrets vs Environment Variables

| Docker Secrets | Environment Variables (`.env`) |
|----------------|----------------------------------|
| Passwords in files under `secrets/`, mounted read-only at `/run/secrets/` | Domain name, DB name, usernames, URLs |
| Never committed to git | Template in `.env.example`; real `.env` is gitignored |
| Read by entrypoint scripts at runtime | Injected by Compose into containers |
| Used for DB passwords and WP admin password | Used for non-sensitive configuration |

### Docker Network vs Host Network

| Docker Network (`inception`) | Host Network |
|------------------------------|--------------|
| Containers talk via DNS names (`mariadb`, `wordpress`) | Container shares host network stack directly |
| Only port 443 published to the host (nginx) | Would expose all container ports on the host |
| Isolated, subject-compliant | Forbidden by the subject (`network: host`) |

### Docker Volumes vs Bind Mounts

| Named Volumes (this project) | Bind Mounts |
|------------------------------|-------------|
| Declared in compose `volumes:` section with a logical name | Maps a host path directly in the service `volumes:` entry |
| Data stored under `/home/kebris-c/data/` via `driver_opts.device` | Subject forbids bind mounts for DB and WordPress data |
| Survive `docker compose down`; removed only with `-v` | Same persistence model but not allowed for mandatory volumes |
| Shared between wordpress and nginx (read-only on nginx) | — |

## Resources

1. 42 Inception subject (v5.3) — official project requirements from the 42 intranet.
2. [Docker Documentation](https://docs.docker.com/) — containers, images, volumes, secrets.
3. [Docker Compose file reference](https://docs.docker.com/compose/compose-file/) — services, networks, healthchecks.
4. [NGINX HTTPS configuration](https://nginx.org/en/docs/http/configuring_https_servers.html) — TLS and reverse proxy setup.

### Use of AI

AI tools were used as a **learning aid**, not as a substitute for implementation. They provided general guidelines, architectural suggestions, explanations of Docker/NGINX/PHP-FPM concepts, and starter templates for Dockerfiles, entrypoints, and documentation structure. All code was reviewed, adapted, and is being reimplemented and tested manually to ensure full understanding before evaluation.

Peer discussions and the official subject document were the primary references for compliance decisions.

## See also

- [USER_DOC.md](USER_DOC.md) — operator documentation
- [DEV_DOC.md](DEV_DOC.md) — developer setup from scratch
