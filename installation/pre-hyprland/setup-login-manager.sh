#!/bin/bash
set -euo pipefail

echo "Setting up ly login manager..."
sudo -v

REPO_ROOT=$(pwd)
CONFIG_DIR="$REPO_ROOT/configs"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: 'configs/' directory not found in repo root."
    exit 1
fi

# ---- config dirs ----
sudo mkdir -p /etc/ly

# ---- Copy config files ----
sudo cp $CONFIG_DIR/etc/ly/config.ini /etc/ly/

# ---- Enable ly service ----
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service