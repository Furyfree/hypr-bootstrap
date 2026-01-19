#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

log "Setting up ly login manager..."
require_sudo

log "Disabling sddm"
sudo systemctl disable sddm.service >/dev/null 2>&1 || true

log "Uninstalling sddm"
if pacman -Qi sddm >/dev/null 2>&1; then
    sudo pacman -Rns --noconfirm sddm
else
    log "sddm not installed, skipping removal"
fi

CONFIG_DIR="$REPO_ROOT/configs"

if [ ! -d "$CONFIG_DIR" ]; then
    die "configs/ directory not found in repo root"
fi

# ---- config dirs ----
sudo mkdir -p /etc/ly

# ---- Copy config files ----
sudo cp "$CONFIG_DIR/etc/ly/config.ini" /etc/ly/

# ---- Enable ly service ----
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service
