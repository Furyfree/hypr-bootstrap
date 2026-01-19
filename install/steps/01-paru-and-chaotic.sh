#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_sudo

# Check if the rust package itself is installed and remove it (avoid rustup provides)
if pacman -Qq rust 2>/dev/null | grep -qx "rust"; then
    log "Removing rust via pacman..."
    sudo pacman -R --noconfirm rust
else
    log "rust package not installed, skipping."
fi

log "Installing minimal requirements..."
sudo pacman -Syu --needed --noconfirm base-devel git rustup
rustup default stable

# Install paru AUR helper (only if not already present)
if ! command -v paru &>/dev/null; then
    log "paru not found → installing from AUR..."

    TMP_DIR="/tmp/paru-install-$(date +%s)"
    git clone https://aur.archlinux.org/paru.git "$TMP_DIR"
    cd "$TMP_DIR"
    makepkg -si --noconfirm --needed
    cd ~
    rm -rf "$TMP_DIR"

    # Quick safety check
    if ! command -v paru &>/dev/null; then
        die "paru installation failed"
    fi

    log "paru successfully installed."
else
    log "paru is already installed, skipping."
fi

# Paru config (from xerolinux guide)
log "Configuring paru AUR helper..."
sudo sed -i -e 's/^#BottomUp/BottomUp/' \
           -e 's/^#SudoLoop/SudoLoop/' \
           -e 's/^#CombinedUpgrade/CombinedUpgrade/' \
           -e 's/^#UpgradeMenu/UpgradeMenu/' \
           -e 's/^#NewsOnUpgrade/NewsOnUpgrade/' /etc/paru.conf

echo "SkipReview" | sudo tee -a /etc/paru.conf >/dev/null
paru --gendb

log "Setting up paccache.timer (automatic cache cleanup)..."
if ! pacman -Q pacman-contrib &>/dev/null; then
    sudo pacman -S --needed --noconfirm pacman-contrib
fi
sudo systemctl enable --now paccache.timer

log "AUR helper setup complete."

# Chaotic-AUR setup

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U --noconfirm --needed 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm --needed 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Add Chaotic-AUR to pacman.conf
if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
    echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf >/dev/null
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null
else
    log "Chaotic-AUR already configured, skipping pacman.conf update."
fi

log "Chaotic-AUR setup complete."

log "Updating repository"
sudo pacman -Syyu --noconfirm
