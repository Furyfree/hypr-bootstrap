#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/../packages.txt"

# Read packages, skip comments (#) and empty lines
PACKAGES=$(grep -v '^\s*#' "$PACKAGES_FILE" | grep -v '^\s*$')

paru -S --needed --noconfirm $PACKAGES

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    echo "xdg-user-dirs-update is already installed - running it"
    xdg-user-dirs-update
else
    echo "xdg-user-dirs-update not found - installing xdg-user-dirs..."
    sudo pacman -S --needed xdg-user-dirs
    echo "Running xdg-user-dirs-update now..."
    xdg-user-dirs-update
fi