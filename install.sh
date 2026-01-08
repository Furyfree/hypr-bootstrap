#!/bin/bash

# Main installation script for Hyprland bootstrap
# Run this from the repo root

set -euo pipefail

REPO_ROOT=$(pwd)

echo "=== Starting Hyprland Bootstrap Installation ==="
echo

echo "Step 1: Setting up AUR helper (paru)..."
source "$REPO_ROOT/installation/pre-hyprland/setup-aur.sh"
echo

echo "Step 2: Setting up Chaotic AUR..."
source "$REPO_ROOT/installation/pre-hyprland/setup-chaotic-aur.sh"
echo

echo "Step 3: Installing packages..."
source "$REPO_ROOT/installation/pre-hyprland/install-packages.sh"
echo

echo "Step 4: Setting up auto-unlock FDE..."
source "$REPO_ROOT/installation/pre-hyprland/setup-autounlock-fde.sh"
echo

echo "Step 5: Setting up login manager (regreet)..."
source "$REPO_ROOT/installation/pre-hyprland/setup-login-manager-regreet.sh"
echo

echo "Step 6: Installing graphics drivers..."
source "$REPO_ROOT/installation/hyprland/install-graphics-drivers.sh"
echo

echo "Step 7: Installing config files..."
source "$REPO_ROOT/installation/hyprland/install-configs.sh"
echo

echo "Step 8: Setting up VS Code OSS..."
source "$REPO_ROOT/installation/hyprland/code-oss.sh"
echo

echo "Step 9: Setting up Elephant launcher..."
source "$REPO_ROOT/installation/hyprland/launcher/elephant.sh"
echo

echo "Step 10: Setting up Walker launcher..."
source "$REPO_ROOT/installation/hyprland/launcher/walker.sh"
echo

echo "=== Installation Complete ==="