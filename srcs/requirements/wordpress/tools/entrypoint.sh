#!/bin/bash
set -e

DB_PASS="$(cat /run/secrets/db_password)"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"

wait_for_db() {
	echo "Waiting for MariaDB at ${WORDPRESS_DB_HOST}..."
	until mysqladmin ping -h"${WORDPRESS_DB_HOST}" -u"${WORDPRESS_DB_USER}" -p"${DB_PASS}" --silent 2>/dev/null; do
		sleep 2
	done
	echo "MariaDB is ready."
}

wait_for_db

if [ ! -f /var/www/html/wp-settings.php ]; then
	echo "Downloading WordPress..."
	wp core download --allow-root --path=/var/www/html --version=6.4.3
fi

if [ ! -f /var/www/html/wp-config.php ]; then
	wp config create --allow-root --path=/var/www/html \
		--dbname="${WORDPRESS_DB_NAME}" \
		--dbuser="${WORDPRESS_DB_USER}" \
		--dbpass="${DB_PASS}" \
		--dbhost="${WORDPRESS_DB_HOST}" \
		--skip-check
fi

if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
	echo "Installing WordPress..."
	wp core install --allow-root --path=/var/www/html \
		--url="${WORDPRESS_URL}" \
		--title="${WORDPRESS_TITLE}" \
		--admin_user="${WORDPRESS_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASS}" \
		--admin_email="${WORDPRESS_ADMIN_EMAIL}" \
		--skip-email

	wp user create "${WORDPRESS_SECOND_USER}" "${WORDPRESS_SECOND_EMAIL}" \
		--allow-root --path=/var/www/html \
		--role="${WORDPRESS_SECOND_ROLE}" \
		--user_pass="${WORDPRESS_SECOND_PASSWORD}" \
		--display_name="${WORDPRESS_SECOND_USER}"
fi

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

exec php-fpm8.2 -F
