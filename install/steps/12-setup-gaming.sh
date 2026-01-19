#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_sudo
require_paru

log "Starting basic gaming setup..."

# ====================
# Core Gaming Packages
# ====================
log "Installing gaming essentials..."
GAMING_PKGS=(
    # Performance tools
    gamemode
    lib32-gamemode
    mangohud
    lib32-mangohud
    python-vdf
)

sudo pacman -S --needed --noconfirm "${GAMING_PKGS[@]}"

# ====================
# Game Launchers (AUR)
# ====================
log "Installing game launchers..."
AUR_PKGS=(
    faugus-launcher
    minecraft-launcher
)

paru -S --needed --noconfirm "${AUR_PKGS[@]}"

# ====================
# Summary
# ====================
log "Gaming setup complete!"
