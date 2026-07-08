#!/bin/sh
# =============================================================================
# NGINX — Optional entrypoint (if you need envsubst for DOMAIN_NAME)
# =============================================================================
# PURPOSE: Replace placeholders in config at runtime using env vars.
#
# Example: envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/default.conf.template
#
# If configs are static, you may skip this and use CMD only.
# =============================================================================

# TODO: Optional — template substitution then exec nginx

# exec nginx -g "daemon off;"

echo "Optional: implement if using config templates"
exit 0
