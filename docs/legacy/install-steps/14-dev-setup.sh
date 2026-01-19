#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Copy config.toml
echo "Setting up mise..."
if ! command -v mise >/dev/null 2>&1; then
  echo "mise not found, installing..."
  sudo pacman -S --needed --noconfirm mise
fi

mkdir -p "$HOME/.config/mise"
cp "$REPO_ROOT/configs/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
mise install

echo "==> Arduino / PlatformIO setup (Arch Linux)"

# must not be run as root
if [ "$(id -u)" -eq 0 ]; then
  echo "Run this script as a normal user, not root."
  exit 1
fi

# packages
echo "-> Installing PlatformIO Core"
sudo pacman -S --needed --noconfirm platformio-core

# user groups (serial access)
echo "-> Adding user to uucp and lock groups"
sudo usermod -aG uucp,lock "$USER"

# udev rules (robust USB access)
RULES="/etc/udev/rules.d/99-platformio-udev.rules"
if [ ! -f "$RULES" ]; then
  echo "-> Installing PlatformIO udev rules"
  sudo curl -fsSL \
    https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules \
    -o "$RULES"
else
  echo "-> udev rules already present"
fi

echo "-> Reloading udev rules"
sudo udevadm control --reload-rules
sudo udevadm trigger

echo
echo "Done."
echo "IMPORTANT: log out and log back in for group changes to take effect."
