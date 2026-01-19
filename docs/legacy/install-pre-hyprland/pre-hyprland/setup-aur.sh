#!/bin/bash
set -euo pipefail

# Refresh sudo once at start (helps for initial deps)
sudo -v

echo "Installing minimal requirements..."
sudo pacman -Sy --needed --noconfirm base-devel git rustup
rustup default stable

# Install paru AUR helper (only if not already present)
if ! command -v paru &>/dev/null; then
    echo "paru not found → installing from AUR..."

    TMP_DIR="/tmp/paru-install-$(date +%s)"
    git clone https://aur.archlinux.org/paru.git "$TMP_DIR"
    cd "$TMP_DIR"
    makepkg -si --noconfirm --needed
    cd ~
    rm -rf "$TMP_DIR"

    # Quick safety check
    if ! command -v paru &>/dev/null; then
        echo "ERROR: paru installation failed!"
        exit 1
    fi

    echo "paru successfully installed."
else
    echo "paru is already installed, skipping."
fi

# Paru config (from xerolinux guide)
echo "Configuring paru AUR helper..."
sudo sed -i -e 's/^#BottomUp/BottomUp/' \
           -e 's/^#SudoLoop/SudoLoop/' \
           -e 's/^#CombinedUpgrade/CombinedUpgrade/' \
           -e 's/^#UpgradeMenu/UpgradeMenu/' \
           -e 's/^#NewsOnUpgrade/NewsOnUpgrade/' /etc/paru.conf

echo "SkipReview" | sudo tee -a /etc/paru.conf >/dev/null
paru --gendb

echo "Setting up paccache.timer (automatic cache cleanup)..."
if ! pacman -Q pacman-contrib &>/dev/null; then
    sudo pacman -S --needed --noconfirm pacman-contrib
fi
sudo systemctl enable --now paccache.timer

echo "AUR helper setup complete."