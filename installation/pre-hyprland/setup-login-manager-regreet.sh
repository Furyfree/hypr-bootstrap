#!/usr/bin/env bash
set -euo pipefail

echo "Setting up greetd + regreet"
sudo -v

REPO_ROOT=$(pwd)
CONFIG_DIR="$REPO_ROOT/configs"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: 'configs/' directory not found in repo root."
    exit 1
fi

# ---- config dirs ----
sudo mkdir -p /etc/greetd

# ---- Copy config files ----
sudo cp -r $CONFIG_DIR/etc/greetd/ /etc/greetd/

sudo systemctl enable --now greetd
