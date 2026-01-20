#!/bin/bash
set -euo pipefail

echo "Changing default shell to zsh"
sudo -v # Refresh sudo credentials

# Check if ZSH is installed
if ! command -v zsh &>/dev/null; then
    echo "Zsh is not installed. Installing zsh..."
    sudo pacman -S --noconfirm zsh
fi

# Change the default shell to ZSH for the current user
if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "Changing default shell to zsh for user $USER..."
    sudo chsh -s "$(command -v zsh)" "$USER"
else
    echo "Default shell is already zsh."
fi

# Add zshrc and zsh configs
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ZSHRC="$REPO_ROOT/configs/.zshrc"
ZSH_CONFIG="$REPO_ROOT/configs/.config/zsh"

mkdir -p "$HOME/.config"
cp "$ZSHRC" "$HOME/.zshrc"
if [ -d "$ZSH_CONFIG" ]; then
    mkdir -p "$HOME/.config/zsh"
    cp -r "$ZSH_CONFIG"/. "$HOME/.config/zsh"
else
    echo "WARNING: $ZSH_CONFIG not found, skipping zsh config copy"
fi
