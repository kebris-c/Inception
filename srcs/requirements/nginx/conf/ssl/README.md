# =============================================================================
# TLS certificates — generate on VM, do not commit private keys
# =============================================================================
#
# Generate self-signed certificate (replace login):
#
#   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#     -keyout nginx.key \
#     -out nginx.crt \
#     -subj "/CN=your_login.42.fr"
#
# Place nginx.crt and nginx.key here before docker build,
# OR generate in Dockerfile RUN step (document in DEV_DOC.md).
#
# Files expected:
#   nginx.crt  — certificate (can be in image)
#   nginx.key    — private key (keep out of git — listed in .gitignore)
# =============================================================================
