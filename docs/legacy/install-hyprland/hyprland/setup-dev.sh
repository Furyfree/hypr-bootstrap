#!/bin/bash
set -euo pipefail

sudo -v  # Refresh sudo credentials
echo "Setting up development environment for Hyprland..."

sudo pacman -S --noconfirm --needed base-devel gcc clang docker docker-compose tk

# Enable Docker service
sudo systemctl enable --now docker.service
sudo systemctl enable --now docker.socket

# Add user to docker group (logout/login to apply)
sudo usermod -aG docker "$USER"
echo "Added $USER to docker group. Log out/in for changes."

# Install Mise (Environment manager for multiple languages)
if ! command -v mise &> /dev/null; then
    echo "Installing Mise..."
    curl https://mise.run | sh
fi

# Smart mise install: only if doctor finds issues
if mise doctor --quiet | grep -q "."; then
    # If doctor outputs anything in quiet mode, something is wrong/missing/outdated
    echo "Issues detected by mise doctor"
    echo "Running mise install..."
    mise install
else
    echo "mise doctor reports everything is healthy and up-to-date. Skipping install."
fi

# Clean up old unused versions
echo "Pruning old tool versions..."
mise prune --yes

# Self-update mise to latest version
echo "Updating mise to latest version..."
mise self-update

echo "Development environment setup for Hyprland completed."