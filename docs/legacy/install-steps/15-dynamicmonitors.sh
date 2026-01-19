#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Refresh sudo
sudo -v

echo "Setting up Hyprland dynamic monitors..."

# Install Hyprland dynamic monitors
if ! command -v paru >/dev/null 2>&1; then
    echo "ERROR: paru not found. Run 01-paru-and-chaotic.sh first."
    exit 1
fi
paru -S --noconfirm --needed hyprdynamicmonitors-bin

# Copy configs
mkdir -p "$HOME/.config"
cp -r "$REPO_ROOT/configs/.config/hyprdynamicmonitors" "$HOME/.config/"

echo "Finished setting up Hyprland dynamic monitors"
