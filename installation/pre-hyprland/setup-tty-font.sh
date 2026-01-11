#!/bin/bash
set -euo pipefail

FONT="ter-132b"
CONFIG="/etc/vconsole.conf"
BACKUP="${CONFIG}.bak.$(date +%Y%m%d-%H%M%S)"

echo "Setting permanent console font to $FONT"

# Backup original
if [[ -f "$CONFIG" ]]; then
    sudo cp "$CONFIG" "$BACKUP"
    echo "→ Backup created: $BACKUP"
else
    echo "→ No existing config, creating new one"
fi

# Remove old FONT= line if present, then append new one
sudo sed -i '/^FONT=/d' "$CONFIG" 2>/dev/null || true
echo "FONT=$FONT" | sudo tee -a "$CONFIG" >/dev/null

# Apply immediately
sudo systemctl restart systemd-vconsole-setup

echo "Done! Test now: Ctrl+Alt+F3 (back with Ctrl+Alt+F2)"
echo "If font resets after full reboot → ensure 'consolefont' hook is in /etc/mkinitcpio.conf HOOKS and run:"
echo "sudo mkinitcpio -P"