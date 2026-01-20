#!/bin/bash
set -euo pipefail

echo "==> [Netstack] Switching to NetworkManager + iwd stack"

# --- Detect current backend ---
detect_backend() {
    if systemctl is-active --quiet NetworkManager; then
        if systemctl is-active --quiet iwd; then
            if systemctl is-active --quiet systemd-networkd; then
                echo "systemd-iwd"
            else
                echo "nm-iwd"
            fi
        else
            echo "nm-wpa"
        fi
    elif systemctl is-active --quiet iwd && systemctl is-active --quiet systemd-networkd; then
        echo "systemd-iwd"
    else
        echo "none"
    fi
}

backend="$(detect_backend)"
echo "--> Active backend: $backend"

# --- Main switch logic ---
if [ "$backend" = "nm-iwd" ]; then
    echo "--> NetworkManager with iwd is already active"
else
    echo "--> Installing dependencies"
    sudo pacman -S --needed --noconfirm networkmanager iwd

    echo "--> Disabling wpa_supplicant and systemd-networkd"
    sudo systemctl disable --now wpa_supplicant.service \
        systemd-networkd.service systemd-networkd-wait-online.service \
        systemd-networkd.socket systemd-networkd-varlink.socket \
        systemd-networkd-resolve-hook.socket || true
    sudo systemctl mask wpa_supplicant.service || true

    echo "--> Masking systemd-networkd sockets"
    sudo systemctl mask systemd-networkd.socket \
        systemd-networkd-varlink.socket \
        systemd-networkd-resolve-hook.socket || true

    echo "--> Enabling and starting iwd"
    sudo systemctl unmask iwd.service || true
    sudo systemctl enable --now iwd.service

    echo "--> Writing NetworkManager config"
    sudo install -d /etc/NetworkManager/conf.d
    sudo tee /etc/NetworkManager/NetworkManager.conf >/dev/null <<'EOF'
[main]
plugins=keyfile
dns=systemd-resolved
rc-manager=symlink
EOF
    sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf >/dev/null <<'EOF'
[device]
wifi.backend=iwd
EOF

    echo "--> Enabling and restarting NetworkManager"
    sudo systemctl enable --now NetworkManager.service
    sudo systemctl restart NetworkManager.service
fi

# --- Final validation ---
rfkill unblock wifi || true
nmcli networking on >/dev/null 2>&1 || true
nmcli radio wifi on >/dev/null 2>&1 || true

echo "--> Verifying services"
for svc in iwd systemd-networkd wpa_supplicant NetworkManager; do
    if systemctl is-active --quiet "$svc"; then
        echo "   $svc: active"
    else
        echo "   $svc: inactive"
    fi
done

sleep 10
echo "--> Current backend: $(detect_backend)"
echo "==> [Netstack] Netstack configuration complete"
