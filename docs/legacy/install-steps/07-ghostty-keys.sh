#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KEYBINDINGS_CONF="$REPO_ROOT/configs/.config/ghostty/keybindings"

# Copy config
mkdir -p "$HOME/.config/ghostty"
cp "$KEYBINDINGS_CONF" "$HOME/.config/ghostty/keybindings"

# Append keybindings
CONFIG_FILE="$HOME/.config/ghostty/config"
touch "$CONFIG_FILE"
if ! grep -qx "config-file = keybindings" "$CONFIG_FILE"; then
    echo "config-file = keybindings" >> "$CONFIG_FILE"
fi
