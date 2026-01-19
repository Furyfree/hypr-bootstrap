#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

APPS_DIR="$REPO_ROOT/configs/applications"
ICONS_DIR="$REPO_ROOT/configs/icons"
LOCAL_APPS="$HOME/.local/share/applications"
LOCAL_ICONS="$HOME/.local/share/icons"

if [ ! -d "$APPS_DIR" ]; then
    die "Applications directory not found at $APPS_DIR"
fi

log "Setting up applications..."

mkdir -p "$LOCAL_APPS"

# Setup regular applications
for app in "$APPS_DIR"/*.desktop; do
    if [ -f "$app" ]; then
        app_name=$(basename "$app")
        cp "$app" "$LOCAL_APPS/"
        log "Installed $app_name"
    fi
done

# Setup hidden applications
if [ -d "$APPS_DIR/hidden" ]; then
    for app in "$APPS_DIR/hidden"/*.desktop; do
        if [ -f "$app" ]; then
            app_name=$(basename "$app")
            cp "$app" "$LOCAL_APPS/"
            log "Installed $app_name (hidden)"
        fi
    done
fi

# Copy icons if they exist
if [ -d "$ICONS_DIR" ]; then
    mkdir -p "$LOCAL_ICONS"
    if cp -r "$ICONS_DIR/"* "$LOCAL_ICONS/" 2>/dev/null; then
        log "Installed icons"
    fi
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$LOCAL_APPS"
    log "Desktop database updated"
fi

log "Application setup complete"
