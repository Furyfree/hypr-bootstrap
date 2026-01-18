#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
APPS_DIR="$REPO_ROOT/configs/applications"
LOCAL_APPS="$HOME/.local/share/applications"

echo "Setting up applications..."

mkdir -p "$LOCAL_APPS"

# Setup regular applications
for app in "$APPS_DIR"/*.desktop; do
    if [ -f "$app" ]; then
        app_name=$(basename "$app")
        cp "$app" "$LOCAL_APPS/"
        echo "Installed $app_name"
    fi
done

# Setup hidden applications
if [ -d "$APPS_DIR/hidden" ]; then
    for app in "$APPS_DIR/hidden"/*.desktop; do
        if [ -f "$app" ]; then
            app_name=$(basename "$app")
            cp "$app" "$LOCAL_APPS/"
            echo "Installed $app_name (hidden)"
        fi
    done
fi

# Copy icons if they exist
if [ -d "$APPS_DIR/icons" ]; then
    mkdir -p "$HOME/.local/share/icons"
    if cp -r "$APPS_DIR/icons/"* "$HOME/.local/share/icons/" 2>/dev/null; then
        echo "Installed icons"
    fi
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$LOCAL_APPS"
    echo "Desktop database updated"
fi

echo "Application setup complete"
