#!/usr/bin/env bash
set -euo pipefail

echo "Setting up greetd + regreet"

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

EOF

# ---- /etc/greetd/regreet.toml ----
sudo tee /etc/greetd/regreet.toml >/dev/null <<'EOF'
[background]
path = "/usr/share/backgrounds/bc1.png"
fit = "Contain"

[GTK]
application_prefer_dark_theme = true
cursor_theme_name = "macOS"
cursor_blink = true
font_name = "SF Pro Display 16"
icon_theme_name = "Papirus-Dark"

[commands]
reboot = ["systemctl", "reboot"]
poweroff = ["systemctl", "poweroff"]

[appearance]
greeting_msg = "Welcome back!"

[widget.clock]
format = "%a %H:%M"
resolution = "500ms"
timezone = "Europe/Copenhagen"
label_width = 150

EOF

# ---- /etc/greetd/regreet.toml ----
sudo tee /etc/greetd/regreet.css >/dev/null <<'EOF'
* {
  all: unset;
}

/* Background image blur */
picture {
  filter: blur(1.2rem);
}

/* Main frame */
frame.background {
  background: rgba(32, 32, 32, 0.92);
  color: #e6e6e6;
  border-radius: 24px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.6);
}

/* Top bar */
frame.background.top {
  font-size: 1.2rem;
  padding: 8px;
  background: #1e1e1e;
  border-radius: 0;
  border-bottom-left-radius: 24px;
  border-bottom-right-radius: 24px;
}

/* Primary action button */
box.horizontal > button.default.suggested-action.text-button {
  background: #3a82f7;
  color: #ffffff;
  padding: 12px;
  margin: 0 8px;
  border-radius: 12px;
  transition: background 0.3s ease-in-out;
}

box.horizontal > button.default.suggested-action.text-button:hover {
  background: #5a96ff;
}

/* Secondary / cancel buttons */
box.horizontal > button.text-button {
  background: #2a2a2a;
  color: #f0f0f0;
  padding: 12px;
  border-radius: 12px;
  transition: background 0.3s ease-in-out;
}

box.horizontal > button.text-button:hover {
  background: #c0392b;
  color: #ffffff;
}

/* Combobox */
combobox {
  background: #2a2a2a;
  color: #e6e6e6;
  border-radius: 12px;
  padding: 12px;
  box-shadow: 0 0 4px rgba(0, 0, 0, 0.5);
}

combobox:hover {
  background: #353535;
}

combobox:disabled {
  background: #1f1f1f;
  color: rgba(230, 230, 230, 0.5);
}

/* Combobox dropdown */
combobox > popover {
  background: #2a2a2a;
  color: #e6e6e6;
  border-radius: 8px;
  padding: 6px 12px;
  box-shadow: 0 0 4px rgba(0, 0, 0, 0.5);
}

combobox > popover > contents {
  padding: 2px;
}

/* Flat model buttons */
modelbutton.flat {
  background: #2f2f2f;
  padding: 6px;
  margin: 2px;
  border-radius: 8px;
}

modelbutton.flat:hover {
  background: #3a3a3a;
}

/* Image toggle buttons */
button.image-button.toggle {
  margin-right: 36px;
  padding: 12px;
  border-radius: 12px;
}

button.image-button.toggle:hover {
  background: #2a2a2a;
  box-shadow: 0 0 4px rgba(0, 0, 0, 0.5);
}

button.image-button.toggle:disabled {
  background: #1f1f1f;
  color: rgba(230, 230, 230, 0.5);
}

/* Password entry */
entry.password {
  border: 2px solid #3a82f7;
  border-radius: 12px;
  padding: 12px;
}

entry.password:hover {
  border: 2px solid #5a96ff;
}
EOF

sudo systemctl enable --now greetd
