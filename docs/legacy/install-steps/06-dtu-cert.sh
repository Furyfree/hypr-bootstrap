#!/bin/bash
set -euo pipefail

echo "==> [Certs] Installing DTU Eduroam certificate"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_DIR="$REPO_ROOT/configs/system"
CERT_SRC="$CONFIG_DIR/etc/certs/Eduroam_aug2020.pem"
CERT_DST="/etc/certs/Eduroam_aug2020.pem"

if [ ! -f "$CERT_SRC" ]; then
    echo "Error: certificate not found at $CERT_SRC"
    exit 1
fi

sudo mkdir -p /etc/certs
sudo cp "$CERT_SRC" "$CERT_DST"

echo "[Certs] --> Updating system CA trust"
if command -v update-ca-trust >/dev/null 2>&1; then
    sudo update-ca-trust
elif command -v trust >/dev/null 2>&1; then
    sudo trust extract-compat
else
    echo "WARNING: no CA trust update command found"
fi

echo "==> [Certs] Eduroam certificate installation complete"
