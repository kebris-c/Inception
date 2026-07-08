# =============================================================================
# WordPress + PHP-FPM — Dockerfile
# =============================================================================
# PURPOSE: WordPress files + php-fpm only. NO nginx in this container.
#
# STEPS TO COMPLETE:
#   1. Base: Debian or Alpine with php-fpm + required extensions
#      Extensions: mysqli, curl, gd, mbstring, xml, zip (typical WP needs)
#   2. Download WordPress (specific version tarball) OR install wp-cli
#   3. COPY conf/php-fpm pool config, tools/entrypoint.sh
#   4. WORKDIR /var/www/html
#   5. CMD ["php-fpm", "-F"]  (foreground)
# =============================================================================

# TODO: FROM debian:bookworm-slim or alpine:3.19

# TODO: Install php-fpm and extensions
# RUN apt-get install -y php-fpm php-mysqli ...

# TODO: Install wp-cli (optional but recommended)
# RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# TODO: Download WordPress to /var/www/html (or let entrypoint copy on first run)

# COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
# COPY tools/entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh

# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["php-fpm", "-F"]
