#!/bin/sh
# =============================================================================
# WordPress — Entrypoint script
# =============================================================================
# PURPOSE: Wait for DB, install WordPress once, create 2 users, start php-fpm.
#
# FLOW:
#   1. Wait until mariadb:3306 accepts connections (nc, mysqladmin, or loop)
#   2. Read env (.env) + secrets (/run/secrets/)
#   3. Generate wp-config.php from env if missing
#   4. wp core install (first run only) — URL = https://${DOMAIN_NAME}
#   5. wp user create for SECOND user (subject requirement)
#   6. Admin username must NOT contain admin/administrator
#   7. chown -R www-data:www-data /var/www/html
#   8. exec php-fpm -F
#
# TODO: Implement full entrypoint
# =============================================================================

set -e

# TODO: wait_for_db

# TODO: wp core is-installed || wp core install ...

# TODO: wp user create ${WORDPRESS_SECOND_USER} ...

# TODO: exec php-fpm -F

echo "TODO: Complete wordpress entrypoint.sh"
exit 1
