# User Documentation — Inception

Audience: **end user or system administrator** who needs to run the website stack without reading Docker internals.

---

## What services are provided?

| Service | What it does for you |
|---------|----------------------|
| **Website** | WordPress site at `https://kebris-c.42.fr` |
| **Admin panel** | WordPress dashboard at `https://kebris-c.42.fr/wp-admin` |
| **Database** | MariaDB (internal — not exposed to the host) |

The only public entry point is **HTTPS on port 443** (NGINX).

---

## Starting and stopping the project

From the project root on the VM:

```bash
make up      # Start all services
make down    # Stop all services
make ps      # Check status
make logs    # View logs if something fails
```

Containers use `restart: unless-stopped`, so they come back after a VM reboot unless you ran `make down`.

---

## Accessing the website

1. Ensure `/etc/hosts` on your machine maps `kebris-c.42.fr` to the VM IP address.
2. Open a browser: **https://kebris-c.42.fr**
3. Accept the self-signed certificate warning (expected in development).

### Administration panel

- URL: **https://kebris-c.42.fr/wp-admin**
- Username: value of `WORDPRESS_ADMIN_USER` in `srcs/.env` (default: `siteowner`)
- Password: stored in `secrets/wp_admin_password.txt` on the VM

---

## Credentials

| Credential | Location |
|------------|----------|
| DB user password | `secrets/db_password.txt` |
| DB root password | `secrets/db_root_password.txt` |
| WordPress admin password | `secrets/wp_admin_password.txt` |
| Second WP user password | `srcs/.env` → `WORDPRESS_SECOND_PASSWORD` |

**Security:** Never commit or share these files. They are excluded from git.

---

## Checking that services are running

```bash
make ps
```

Expected: three containers (`nginx`, `wordpress`, `mariadb`) in state **running**.

### Quick health checks

```bash
curl -k -I https://kebris-c.42.fr
openssl s_client -connect kebris-c.42.fr:443 -tls1_2 </dev/null 2>/dev/null | head -5
```

- Website loads over HTTPS
- You can log in to wp-admin
- After `make down` then `make up`, posts and users still exist (persistence)

---

## Troubleshooting (user level)

| Problem | What to try |
|---------|-------------|
| Site unreachable | Check VM IP, `/etc/hosts`, firewall on port 443 |
| Certificate error | Expected with self-signed cert — proceed in browser |
| White screen / 502 | Run `make logs` and contact developer (see DEV_DOC.md) |
| Forgot admin password | Read `secrets/wp_admin_password.txt` on the VM |

For technical setup, see [DEV_DOC.md](DEV_DOC.md).
