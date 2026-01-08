#!/bin/bash
set -euo pipefail

# Script to detect GPU and install open-source graphics drivers on Arch Linux
# Requires: lspci (from pciutils package - install if missing: sudo pacman -S pciutils)

sudo -v  # Refresh sudo credentials
echo "Starting GPU detection and driver installation..."

if ! command -v lspci &> /dev/null; then
    echo "lspci not found. Installing pciutils..."
    sudo pacman -S --noconfirm pciutils
fi

echo "Detecting GPUs..."
GPU_OUTPUT=$(lspci | grep -E "VGA|3D|Display")

echo "$GPU_OUTPUT"

VENDORS=()

if echo "$GPU_OUTPUT" | grep -iq "nvidia"; then
    VENDORS+=("nvidia")
fi
if echo "$GPU_OUTPUT" | grep -iq "amd\|ati\|radeon"; then
    VENDORS+=("amd")
fi
if echo "$GPU_OUTPUT" | grep -iq "intel"; then
    VENDORS+=("intel")
fi

if [ ${#VENDORS[@]} -eq 0 ]; then
    echo "No supported GPU detected. Falling back to basic mesa."
    sudo pacman -S --noconfirm --needed mesa vulkan-icd-loader lib32-mesa lib32-vulkan-icd-loader
    exit 0
fi

echo "Detected vendors: ${VENDORS[*]}"

# Base packages for all
BASE_PKGS="mesa vulkan-icd-loader lib32-mesa lib32-vulkan-icd-loader vulkan-tools"

# Vendor-specific
AMD_PKGS="vulkan-radeon lib32-vulkan-radeon"
INTEL_PKGS="vulkan-intel lib32-vulkan-intel"
NVIDIA_PKGS=""  # Open-source nouveau is in kernel/mesa; no extra for proprietary here

PKGS_TO_INSTALL="$BASE_PKGS"

# Initialize as array
PKGS_TO_INSTALL=($BASE_PKGS)

for vendor in "${VENDORS[@]}"; do
    case $vendor in
        amd)
            PKGS_TO_INSTALL+=($AMD_PKGS)
            ;;
        intel)
            PKGS_TO_INSTALL+=($INTEL_PKGS)
            ;;
        nvidia)
            echo "WARNING: NVIDIA detected. Open-source nouveau may have issues in Hyprland (tearing, low perf)."
            echo "For better results, install proprietary drivers manually:"
            echo "sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils"
            echo "Then follow: https://wiki.hyprland.org/Nvidia/"
            echo "Add env vars to hyprland.conf and kernel params (nvidia-drm.modeset=1)."
            # Still install base for fallback
            ;;
    esac
done

# Expand array properly
sudo pacman -S --noconfirm --needed "${PKGS_TO_INSTALL[@]}"

echo "Installation complete. Reboot and test with:"
echo "vulkaninfo --summary"
echo "vkcube  # (spinning cube test)"
echo "If issues persist (especially NVIDIA), check Hyprland wiki."

# Optional: For hybrid NVIDIA, add note
if echo "$GPU_OUTPUT" | grep -iq "nvidia" && { echo "$GPU_OUTPUT" | grep -iq "intel" || echo "$GPU_OUTPUT" | grep -iq "amd"; }; then
    echo "Hybrid setup detected. For PRIME offload, see Arch Wiki: NVIDIA Optimus or PRIME."
fi