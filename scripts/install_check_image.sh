#!/bin/bash
# Install wrapper for check-image
set -e

CHECK_IMAGE_WRAPPER="/usr/local/bin/check-image"
cat << 'EOF' | sudo tee $CHECK_IMAGE_WRAPPER > /dev/null
#!/bin/bash
# Forward -h/--help directly to Python script to avoid network calls
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  exec python3 /opt/arm-migration-tools/src/check-image.py "$@"
else
  exec python3 /opt/arm-migration-tools/src/check-image.py "$@"
fi
EOF
sudo chmod +x $CHECK_IMAGE_WRAPPER
