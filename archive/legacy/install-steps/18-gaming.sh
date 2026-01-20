#!/bin/bash
set -euo pipefail

echo "==> [Gaming] Running Gaming Setup"

# --- Steam installation ---
if ! command -v steam >/dev/null 2>&1; then
  if command -v omarchy-install-steam >/dev/null 2>&1; then
    echo "[Gaming] --> Installing Steam"
    omarchy-install-steam
    echo "[Gaming] --> Steam installed successfully"
  else
    echo "[Gaming] WARNING: omarchy-install-steam command not found"
  fi
else
  echo "[Gaming] --> Steam already installed, skipping"
fi


# --- Install gamemode if missing ---
if ! command -v gamemode >/dev/null 2>&1; then
  echo "[Gaming] --> Installing gamemode"
  sudo pacman -S --needed --noconfirm gamemode
else
  echo "[Gaming] --> gamemode already installed"
fi


# --- Install faugus-launcher (AUR) ---
if ! command -v faugus-launcher >/dev/null 2>&1; then
  if command -v paru >/dev/null 2>&1; then
    echo "[Gaming] --> Installing faugus-launcher (AUR)"
    paru -S --aur --needed --noconfirm python-vdf
    paru -S --aur --needed --noconfirm faugus-launcher
  else
    echo "[Gaming] ERROR: paru not found, cannot install faugus-launcher"
  fi
else
  echo "[Gaming] --> faugus-launcher already installed"
fi

# --- Minecraft ---
if ! command -v minecraft-launcher >/dev/null 2>&1; then
  echo "[Gaming] --> Installing Minecraft"
  sudo pacman -S --noconfirm minecraft-launcher

  echo "[Gaming] --> Launching Minecraft"
  setsid gtk-launch minecraft-launcher >/dev/null 2>&1 &
else
  echo "[Gaming] --> Minecraft already installed"
fi


echo "==> [Gaming] Gaming Setup Complete"
