#!/bin/bash
set -euo pipefail

echo "==> [WoW Addons] Installing Wago and WowUp Addon Managers"

# --- Wago setup ---
WAGO_DIR="$HOME/Apps/Wago"
WAGO_FILE="$WAGO_DIR/Wago.AppImage"
WAGO_VERSION="2.9.4"
mkdir -p "$WAGO_DIR"

if [ -f "$WAGO_FILE" ]; then
  echo "--> Wago AppImage already exists, skipping"
else
  echo "--> Downloading Wago AppImage..."
  curl -fL --retry 3 --retry-delay 2 \
    -o "$WAGO_FILE" \
    "https://wago-addons.ams3.digitaloceanspaces.com/wagoapp/WagoApp_$WAGO_VERSION.AppImage"
  chmod +x "$WAGO_FILE"
  echo "[WoW Addons] Wago App installed"
fi

# Register scheme handler if Wago.desktop exists
if [ -f "$HOME/.local/share/applications/Wago.desktop" ]; then
  echo "[WoW Addons] Registering Wago URL handler"
  xdg-mime default Wago.desktop x-scheme-handler/wago-app
fi

# --- WowUp setup ---
WOWUP_DIR="$HOME/Apps/WowUp"
WOWUP_FILE="$WOWUP_DIR/WowUp.AppImage"
WOWUP_VERSION="2.22.0"
mkdir -p "$WOWUP_DIR"

if [ -f "$WOWUP_FILE" ]; then
  echo "--> WowUp AppImage already exists, skipping"
else
  echo "--> Downloading WowUp AppImage..."
  curl -fL --retry 3 --retry-delay 2 \
    -o "$WOWUP_FILE" \
    "https://github.com/WowUp/WowUp.CF/releases/download/v$WOWUP_VERSION/WowUp-CF-$WOWUP_VERSION.AppImage"
  chmod +x "$WOWUP_FILE"
  echo "[WoW Addons] WowUp App installed"
fi

# Register scheme handler if Wowup.desktop exists
if [ -f "$HOME/.local/share/applications/Wowup.desktop" ]; then
  echo "[WoW Addons] Registering WowUp URL handler"
  xdg-mime default Wowup.desktop x-scheme-handler/wowup-app
fi

echo "==> [WoW Addons] Finished installing Wago and WowUp Addon Managers"
