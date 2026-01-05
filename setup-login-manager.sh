#!/usr/bin/env bash
set -euo pipefail

echo "Setting up greetd + regreet"

# ---- packages ----
sudo pacman -S --needed --noconfirm greetd regreet hyprland

# ---- config dirs ----
sudo mkdir -p /etc/greetd

# ---- /etc/greetd/config.toml ----
sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
command = "start-hyprland -- -c /etc/greetd/hyprland.conf"
user = "greeter"
EOF

# ---- /etc/greetd/hyprland.conf ----
sudo tee /etc/greetd/hyprland.conf >/dev/null <<'EOF'
exec-once = regreet; hyprctl dispatch exit

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    disable_hyprland_guiutils_check = true
}

env = GTK_USE_PORTAL,0
env = GDK_DEBUG,no-portals
EOF

# ---- /etc/greetd/regreet.toml ----




sudo systemctl enable --now greetd