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
    sudo chsh -s $(which zsh) $USER
else
    echo "Default shell is already zsh."
fi
