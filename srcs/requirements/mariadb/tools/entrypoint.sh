#!/bin/sh
# =============================================================================
# MariaDB — Entrypoint script
# =============================================================================
# PURPOSE: Initialize database on first start, then exec mysqld as PID 1.
#
# FLOW:
#   1. Read secrets from /run/secrets/db_root_password and db_password
#   2. Export MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD, MYSQL_DATABASE, MYSQL_USER
#   3. If data dir empty → run mysql_install_db / mariadb-install-db
#   4. Start temporary server OR use mysql --initialize
#   5. CREATE DATABASE and CREATE USER if not exists
#   6. exec mysqld (foreground) — NEVER tail -f or sleep infinity
#
# TODO: Implement initialization logic
# TODO: Handle idempotency (safe on container restart)
# =============================================================================

set -e

# TODO: Read secrets
# DB_ROOT_PASS=$(cat /run/secrets/db_root_password)
# DB_PASS=$(cat /run/secrets/db_password)

# TODO: Initialize data directory if empty
# if [ ! -d "/var/lib/mysql/mysql" ]; then
#   ...
# fi

# TODO: exec mysqld — replaces shell as PID 1
# exec mysqld

echo "TODO: Complete mariadb entrypoint.sh"
exit 1
