#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Script to detect GPU and install open-source graphics drivers on Arch Linux
# Requires: lspci (from pciutils package - install if missing: sudo pacman -S pciutils)

require_sudo
log "Starting GPU detection and driver installation..."

if ! command -v lspci &> /dev/null; then
    log "lspci not found. Installing pciutils..."
    sudo pacman -S --noconfirm pciutils
fi

log "Detecting GPUs..."
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
    log "No supported GPU detected. Falling back to basic mesa."
    sudo pacman -S --noconfirm --needed mesa vulkan-icd-loader lib32-mesa lib32-vulkan-icd-loader
    exit 0
fi

log "Detected vendors: ${VENDORS[*]}"

# Base packages for all
BASE_PKGS="mesa vulkan-icd-loader lib32-mesa lib32-vulkan-icd-loader vulkan-tools"

# Vendor-specific
AMD_PKGS="vulkan-radeon lib32-vulkan-radeon"
INTEL_PKGS="vulkan-intel lib32-vulkan-intel"
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
            warn "NVIDIA detected. Open-source nouveau may have issues in Hyprland (tearing, low perf)."
            warn "For better results, install proprietary drivers manually:"
            warn "sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils"
            warn "Then follow: https://wiki.hyprland.org/Nvidia/"
            warn "Add env vars to hyprland.conf and kernel params (nvidia-drm.modeset=1)."
            # Still install base for fallback
            ;;
    esac
done

# Expand array properly
sudo pacman -S --noconfirm --needed "${PKGS_TO_INSTALL[@]}"

log "Installation complete. Reboot and test with:"
log "vulkaninfo --summary"
log "vkcube  # (spinning cube test)"
log "If issues persist (especially NVIDIA), check Hyprland wiki."

# Optional: For hybrid NVIDIA, add note
if echo "$GPU_OUTPUT" | grep -iq "nvidia" && { echo "$GPU_OUTPUT" | grep -iq "intel" || echo "$GPU_OUTPUT" | grep -iq "amd"; }; then
    warn "Hybrid setup detected. For PRIME offload, see Arch Wiki: NVIDIA Optimus or PRIME."
fi
