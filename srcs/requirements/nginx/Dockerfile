# =============================================================================
# NGINX — Dockerfile
# =============================================================================
# PURPOSE: HTTPS reverse proxy — ONLY entry point to infrastructure (port 443).
#
# STEPS TO COMPLETE:
#   1. Base: Debian or Alpine + nginx package (pinned version)
#   2. COPY conf/nginx.conf, conf/default.conf or conf/ssl/
#   3. Generate or COPY self-signed TLS cert for DOMAIN_NAME
#   4. CMD ["nginx", "-g", "daemon off;"]
#
# FORBIDDEN: Exposing port 80 if subject says 443 only — read eval sheet.
# =============================================================================

# TODO: FROM debian:bookworm-slim or alpine:3.19
# RUN apt-get install -y nginx openssl

# COPY conf/nginx.conf /etc/nginx/nginx.conf
# COPY conf/default.conf /etc/nginx/conf.d/default.conf
# COPY conf/ssl/ /etc/nginx/ssl/

# EXPOSE 443
# CMD ["nginx", "-g", "daemon off;"]
