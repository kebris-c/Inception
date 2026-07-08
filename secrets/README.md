# Secrets directory

**Do not commit real password files.**

Create these files locally on your VM (one secret per file, single line, no quotes):

| File | Purpose |
|------|---------|
| `db_password.txt` | Password for WordPress DB user (`MYSQL_USER`) |
| `db_root_password.txt` | MariaDB root password |
| `credentials.txt` | Optional: human-readable summary for your own notes (still not in git) |

Example:

```bash
openssl rand -base64 32 > db_password.txt
openssl rand -base64 32 > db_root_password.txt
chmod 600 *.txt
```

Referenced in `srcs/docker-compose.yml` as Docker secrets.
