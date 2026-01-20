#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

BASE="$REPO_ROOT/install/base.packages"
AUR="$REPO_ROOT/install/aur.packages"

if [ ! -f "$BASE" ]; then
    die "Missing $BASE"
fi
if [ ! -f "$AUR" ]; then
    die "Missing $AUR"
fi

# Install all base packages
require_sudo

mapfile -t packages < <(grep -Ev '^\s*(#|$)' "$BASE")
sudo pacman -S --noconfirm --needed "${packages[@]}"
echo "${packages[@]}"

# Install all AUR packages
require_paru

mapfile -t aur_packages < <(grep -Ev '^\s*(#|$)' "$AUR")

# Filter out packages handled separately.
filtered_packages=()
for pkg in "${aur_packages[@]}"; do
    case "$pkg" in
        ""|zinit|zinit-git|python-vdf|faugus-launcher)
            continue
            ;;
        *)
            filtered_packages+=("$pkg")
            ;;
    esac
done

ZINIT_PKG="${ZINIT_PKG:-zinit}"
if [ -n "$ZINIT_PKG" ]; then
    log "Installing zinit provider: $ZINIT_PKG"
    paru -S --noconfirm --needed "$ZINIT_PKG"
    echo "$ZINIT_PKG"
fi

if [ "${#filtered_packages[@]}" -gt 0 ]; then
    paru -S --noconfirm --needed "${filtered_packages[@]}"
    echo "${filtered_packages[@]}"
fi
