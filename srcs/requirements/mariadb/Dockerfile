# =============================================================================
# MariaDB — Dockerfile
# =============================================================================
# PURPOSE: Build custom MariaDB image from penultimate stable Debian OR Alpine.
# FORBIDDEN: Pulling mariadb image from Docker Hub.
# FORBIDDEN: Passwords in this file — use secrets at runtime.
#
# STEPS TO COMPLETE:
#   1. Choose base: FROM debian:bookworm-slim OR alpine:3.19 (pin version, no latest)
#   2. RUN apt/apk install mariadb-server
#   3. COPY conf/ and tools/entrypoint.sh
#   4. EXPOSE 3306 (internal only — do not publish to host in compose)
#   5. CMD/ENTRYPOINT → run mysqld in foreground (PID 1)
# =============================================================================

# TODO: Replace with penultimate stable base image (specific tag)
# FROM debian:bookworm-slim
# FROM alpine:3.19

# TODO: Install MariaDB server package
# RUN apt-get update && apt-get install -y mariadb-server ...

# TODO: Copy configuration
# COPY conf/ /etc/mysql/conf.d/
# COPY tools/entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh

# TODO: Optional — install tini or dumb-init for proper PID 1
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["mysqld"]
