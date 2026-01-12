#!/bin/bash

########### NOT WORKING YET ###########

# Minimal setup script for QEMU/KVM + libvirt + virt-manager on Arch Linux
# Run as regular user - requires sudo

set -euo pipefail

# Check not running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: Do not run this script as root. Run as regular user with sudo access." >&2
    exit 1
fi

USER=$(whoami)
QEMU_CONF="/etc/libvirt/qemu.conf"

if [ "$USER" = "root" ]; then
    echo "Don't run as root" >&2
    exit 1
fi

echo "Updating system..."
sudo pacman -Syu --noconfirm

echo "Installing packages..."
sudo pacman -S --needed --noconfirm \
    qemu-desktop \
    qemu-hw-display-virtio-gpu-pci-gl \
    qemu-hw-display-virtio-vga-gl \
    virglrenderer \
    libvirt \
    virt-manager \
    virt-viewer \
    dnsmasq \
    edk2-ovmf \
    swtpm \
    qemu-guest-agent \
    spice-vdagent

echo "Enabling libvirt sockets..."
sudo systemctl enable --now libvirtd.socket virtlogd.socket

echo "Adding user to groups..."
sudo usermod -aG libvirt,kvm "$USER"

echo "Configuring QEMU to run as $USER..."
# Backup config if not already backed up
if [ ! -f "${QEMU_CONF}.backup" ]; then
    sudo cp "$QEMU_CONF" "${QEMU_CONF}.backup"
fi

# Check if user/group already configured correctly
CURRENT_USER=$(sudo grep -E '^user\s*=' "$QEMU_CONF" | sed -E 's/.*"(.+)".*/\1/' || echo "")
CURRENT_GROUP=$(sudo grep -E '^group\s*=' "$QEMU_CONF" | sed -E 's/.*"(.+)".*/\1/' || echo "")

if [ "$CURRENT_USER" = "$USER" ] && [ "$CURRENT_GROUP" = "libvirt" ]; then
    echo "QEMU already configured correctly."
else
    # Remove any existing user/group lines (commented or not)
    sudo sed -i '/^#\?user\s*=/d' "$QEMU_CONF"
    sudo sed -i '/^#\?group\s*=/d' "$QEMU_CONF"
    
    # Add new configuration at the end of the file
    echo "user = \"$USER\"" | sudo tee -a "$QEMU_CONF" > /dev/null
    echo "group = \"libvirt\"" | sudo tee -a "$QEMU_CONF" > /dev/null
    
    echo "Updated QEMU configuration."
fi

sudo systemctl restart libvirtd.socket

# Verify libvirtd is running
if ! sudo systemctl is-active --quiet libvirtd.socket; then
    echo "Warning: libvirtd.socket failed to start. Check: systemctl status libvirtd.socket" >&2
fi

echo "Activating default NAT network..."

virsh net-start default 2>/dev/null || true
virsh net-autostart default

echo ""
echo "Setup finished."
echo "→ Log out and log back in (required for group changes)"
echo "→ Then run: virt-manager"
echo ""
echo "If connection fails after relogin:"
echo "  Check: systemctl status libvirtd.socket"
echo "  Test:  virsh list --all"