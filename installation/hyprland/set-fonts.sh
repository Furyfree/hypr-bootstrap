#!/bin/bash
set -euo pipefail

# Color scheme & theme
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface gtk-theme "Graphite-blue-Dark"

# Fonts
gsettings set org.gnome.desktop.interface font-name "SF Pro Text 11"
gsettings set org.gnome.desktop.interface document-font-name "SF Pro Text 11"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10"

# Icons & cursor
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface cursor-theme "macOS"
gsettings set org.gnome.desktop.interface cursor-size 24
hyprctl setcursor macOS 24
