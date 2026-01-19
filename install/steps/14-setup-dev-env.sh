#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_sudo

log "Starting development environment setup..."

# ====================
# Docker Setup
# ====================
log "Configuring Docker..."

if ! command -v docker &>/dev/null; then
    warn "Docker not installed. Installing..."
    sudo pacman -S --needed --noconfirm docker docker-compose
else
    log "Enabling Docker services..."
    sudo systemctl enable --now docker.service
    sudo systemctl enable --now docker.socket

    # Add user to docker group
    if ! groups "$USER" | grep -q docker; then
        log "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
        log "Docker group added. Log out and back in for changes to take effect."
    else
        log "User already in docker group."
    fi
fi

# ====================
# Mise Setup
# ====================
log "Setting up mise (runtime manager)..."

if ! command -v mise &>/dev/null; then
    log "mise not found, installing..."
    sudo pacman -S --needed --noconfirm mise
fi

MISE_CONFIG_SRC="$REPO_ROOT/configs/.config/mise/config.toml"
MISE_CONFIG_DST="$HOME/.config/mise/config.toml"

if [[ -f "$MISE_CONFIG_SRC" ]]; then
    log "Copying mise configuration..."
    mkdir -p "$(dirname "$MISE_CONFIG_DST")"
    cp "$MISE_CONFIG_SRC" "$MISE_CONFIG_DST"
    log "Running mise install..."
    mise install || warn "mise install failed - you may need to configure it manually"
else
    warn "mise config not found at $MISE_CONFIG_SRC, skipping configuration"
fi

# ====================
# PlatformIO Setup (Arduino/Embedded Development)
# ====================
log "Setting up PlatformIO for Arduino/embedded development..."

# Check not running as root
if [ "$(id -u)" -eq 0 ]; then
    die "This script must not be run as root"
fi

# Install PlatformIO Core
if ! command -v platformio &>/dev/null && ! command -v pio &>/dev/null; then
    log "Installing PlatformIO Core..."
    sudo pacman -S --needed --noconfirm platformio-core
else
    log "PlatformIO already installed, skipping."
fi

# Add user to serial access groups
log "Adding $USER to uucp and lock groups (for serial/USB access)..."
sudo usermod -aG uucp,lock "$USER"

# Install udev rules for USB device access
UDEV_RULES="/etc/udev/rules.d/99-platformio-udev.rules"
if [[ ! -f "$UDEV_RULES" ]]; then
    log "Installing PlatformIO udev rules..."
    sudo curl -fsSL \
        https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules \
        -o "$UDEV_RULES" || warn "Failed to download udev rules"

    if [[ -f "$UDEV_RULES" ]]; then
        log "Reloading udev rules..."
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        log "PlatformIO udev rules installed."
    fi
else
    log "PlatformIO udev rules already installed, skipping."
fi

# ====================
# Summary
# ====================
log "Development environment setup complete!"
