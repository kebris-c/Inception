# Secrets directory

**Do not commit real password files.**

Create these files locally on your VM (one secret per file, single line, no quotes):

| File | Purpose |
|------|---------|
| `db_password.txt` | Password for WordPress DB user (`MYSQL_USER`) |
| `db_root_password.txt` | MariaDB root password |
| `wp_admin_password.txt` | WordPress administrator password |
| `credentials.txt` | Optional: your own notes (never commit) |

Quick setup from project root:

```bash
make setup
```

Or manually:

```bash
openssl rand -base64 32 | tr -d '\n' > secrets/db_password.txt
openssl rand -base64 32 | tr -d '\n' > secrets/db_root_password.txt
openssl rand -base64 32 | tr -d '\n' > secrets/wp_admin_password.txt
chmod 600 secrets/*.txt
```

Referenced in `srcs/docker-compose.yml` as Docker secrets.
