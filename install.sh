#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$REPO_ROOT/install/steps"

steps=(
  "$STEPS_DIR/01-paru-and-chaotic.sh"
  "$STEPS_DIR/02-install-apps.sh"
  "$STEPS_DIR/03-graphics-drivers.sh"
  "$STEPS_DIR/04-fde-luks-systemd.sh"
  "$STEPS_DIR/05-login-manager-ly.sh"
  "$STEPS_DIR/06-install-configs.sh"
  "$STEPS_DIR/07-code-oss.sh"
  "$STEPS_DIR/08-setup-scripts.sh"
  "$STEPS_DIR/09-setup-apps.sh"
  "$STEPS_DIR/10-launcher-elephant.sh"
  "$STEPS_DIR/11-setup-monitors.sh"
)

echo "=== Starting Hyprland Bootstrap Installation ==="

for step in "${steps[@]}"; do
  if [ ! -f "$step" ]; then
    echo "ERROR: missing step $step" >&2
    exit 1
  fi
  echo
  echo "==> Running $(basename "$step")"
  bash "$step"
done

echo

echo "=== Installation Complete ==="
