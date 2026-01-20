#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

log "Setting up theming and fonts..."

# Color scheme & theme
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Dark"

# Fonts
gsettings set org.gnome.desktop.interface font-name "SF Pro Text 11"
gsettings set org.gnome.desktop.interface document-font-name "SF Pro Text 11"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10"

# Icons & cursor
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface cursor-theme "macOS"
gsettings set org.gnome.desktop.interface cursor-size 24

# Check if Hyprland is running
if pgrep -x "Hyprland" >/dev/null 2>&1; then
  log "Hyprland is running, applying cursor settings..."
  hyprctl setcursor macOS 24
else
  log "Hyprland not running. Cursor settings will apply on next session."
fi

# Copy backgrounds
BACKGROUNDS_SRC="$REPO_ROOT/configs/backgrounds"
BACKGROUNDS_DST="$HOME/.local/share/backgrounds"

mkdir -p "$BACKGROUNDS_DST"

if [ -d "$BACKGROUNDS_SRC" ]; then
  log "Copying background images..."
  # Copy each file individually
  for bg_file in "$BACKGROUNDS_SRC"/*; do
    if [ -f "$bg_file" ]; then
      cp "$bg_file" "$BACKGROUNDS_DST/"
      log "Copied $(basename "$bg_file")"
    fi
  done
else
  warn "Backgrounds directory not found at $BACKGROUNDS_SRC"
fi

log "Theming setup complete!"
