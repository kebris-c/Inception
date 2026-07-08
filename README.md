*This project has been created as part of the 42 curriculum by `<your_login>`.*

# Inception

## Description

<!-- TODO: 2–3 paragraphs: goal of project, what the stack does, who it is for -->

This project sets up a small containerized infrastructure using Docker Compose on a Virtual Machine. It runs WordPress behind an NGINX reverse proxy with TLS, backed by MariaDB.

**Goal:** Learn system administration through Docker — custom images, networking, volumes, secrets, and process management.

## Instructions

### Prerequisites

- Linux VM with Docker Engine and Docker Compose plugin
- Directories: `/home/<login>/data/mariadb` and `/home/<login>/data/wordpress`
- `/etc/hosts` entry: `<VM_IP> <login>.42.fr`
- Local `secrets/*.txt` files (see `secrets/README.md`)
- Copy `srcs/.env.example` → `srcs/.env` and edit

### Build and run

```bash
make        # build images
make up     # start stack
make down   # stop stack
make logs   # view logs
```

Access: `https://<login>.42.fr`

## Project description

### Docker in this project

<!-- TODO: Explain each component: Makefile, compose, 3 Dockerfiles, volumes, network -->

### Design choices

<!-- TODO: Alpine vs Debian, wp-cli vs manual install, nginx static vs pure fastcgi, etc. -->

### Virtual Machines vs Docker

| Virtual Machines | Docker |
|------------------|--------|
| <!-- TODO --> | <!-- TODO --> |

### Secrets vs Environment Variables

| Secrets | Environment Variables |
|---------|----------------------|
| <!-- TODO --> | <!-- TODO --> |

### Docker Network vs Host Network

| Docker Network | Host Network |
|----------------|--------------|
| <!-- TODO --> | <!-- TODO --> |

### Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|----------------|-------------|
| <!-- TODO --> | <!-- TODO --> |

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX HTTPS](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WordPress wp-cli](https://developer.wordpress.org/cli/commands/)
- [MariaDB KB](https://mariadb.com/kb/en/documentation/)

### Use of AI

<!-- TODO: Describe which tasks AI helped with and how you verified the output -->

## See also

- [INCEPTION_GUIDE.md](INCEPTION_GUIDE.md) — full teaching guide
- [USER_DOC.md](USER_DOC.md) — operator documentation
- [DEV_DOC.md](DEV_DOC.md) — developer setup
