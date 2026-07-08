# User Documentation — Inception

Audience: **end user or system administrator** who needs to run the website stack without reading Docker internals.

---

## What services are provided?

| Service | What it does for you |
|---------|----------------------|
| **Website** | WordPress site at `https://<login>.42.fr` |
| **Admin panel** | WordPress dashboard at `https://<login>.42.fr/wp-admin` |
| **Database** | MariaDB (internal — not directly exposed) |

<!-- TODO: Add bonus services table if implemented -->

---

## Starting and stopping the project

From the project root on the VM:

```bash
make up      # Start all services
make down    # Stop all services
make ps      # Check status
make logs    # View logs if something fails
```

<!-- TODO: Document any reboot behavior (restart: unless-stopped) -->

---

## Accessing the website

1. Ensure DNS or `/etc/hosts` maps `<login>.42.fr` to the VM IP.
2. Open browser: **https://<login>.42.fr**
3. Accept self-signed certificate warning if using dev TLS.

### Administration panel

- URL: **https://<login>.42.fr/wp-admin**
- Log in with the administrator account created at first install.

---

## Credentials

<!-- TODO: Document where credentials live on the VM — NOT in git -->

| Credential | Location |
|------------|----------|
| DB user password | `secrets/db_password.txt` on VM |
| DB root password | `secrets/db_root_password.txt` on VM |
| WordPress admin | Created at install — password in secret or your notes |

**Security:** Do not share or commit password files.

---

## Checking that services are running

```bash
make ps
docker compose -f srcs/docker-compose.yml ps
```

Expected: three containers (`nginx`, `wordpress`, `mariadb`) in state **running**.

### Quick health checks

- Website loads over HTTPS
- Can log in to wp-admin
- After `make down` then `make up`, content and users still exist (persistence)

<!-- TODO: Add curl/openssl examples if helpful -->

---

## Troubleshooting (user level)

| Problem | What to try |
|---------|-------------|
| Site unreachable | Check VM IP, `/etc/hosts`, firewall on 443 |
| Certificate error | Expected with self-signed cert — proceed or install trusted cert |
| White screen | Ask developer to check `make logs` |

For technical setup, see [DEV_DOC.md](DEV_DOC.md).
