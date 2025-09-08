#!/bin/bash
# Install wrapper for porting-advisor
set -e

INSTALL_PREFIX="/opt/arm-migration-tools"
VENV_PATH="$INSTALL_PREFIX/venv"
PORTING_ADVISOR_WRAPPER="/usr/local/bin/porting-advisor"

cat << EOF | sudo tee "$PORTING_ADVISOR_WRAPPER" > /dev/null
#!/bin/bash
exec "$VENV_PATH/bin/python" "$INSTALL_PREFIX/porting-advisor-for-graviton/src/porting-advisor.py" "\$@"
EOF

sudo chmod +x "$PORTING_ADVISOR_WRAPPER"