#!/bin/bash
set -euo pipefail

echo "==> [Wootility] Setting up Wootility (webapp + udev rules)"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT_DIR="$HOME/git/omarchy-bootstrap"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
UDEV_FILE="/etc/udev/rules.d/70-wooting.rules"

mkdir -p "$APP_DIR" "$ICON_DIR"

# Desktop entry + icon
cp "$REPO_ROOT/applications/Wootility.desktop" \
       "$APP_DIR/Wootility.desktop"

ln -sf "$REPO_ROOT/applications/icons/Wootility.png" \
       "$ICON_DIR/Wootility.png"

echo "-> Wootility desktop entry linked"


# Udev rules for WebHID
RULES='
# Wooting One Legacy
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", TAG+="uaccess"

# Wooting One update mode
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", TAG+="uaccess"

# Wooting Two Legacy
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", TAG+="uaccess"

# Wooting Two update mode
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2403", TAG+="uaccess"

# Generic Wooting devices
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", TAG+="uaccess"
'

echo "$RULES" | sudo tee "$UDEV_FILE" >/dev/null

sudo udevadm control --reload-rules
sudo udevadm trigger

echo "-> Wooting udev rules applied"


echo "==> Wootility setup complete"
