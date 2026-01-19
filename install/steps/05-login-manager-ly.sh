#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_sudo

log "Setting up ly login manager..."

# Check if ly is installed
if ! pacman -Qi ly &>/dev/null; then
    log "Installing ly..."
    sudo pacman -S --needed --noconfirm ly
else
    log "ly is already installed."
fi

# Enable ly service on tty2
log "Enabling ly service on tty2..."
sudo systemctl disable getty@tty2.service 2>/dev/null || true
sudo systemctl enable ly@tty2.service

log "ly login manager setup complete!"
