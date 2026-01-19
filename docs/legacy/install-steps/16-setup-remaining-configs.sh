#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIGS="$REPO_ROOT/configs"

copy_file() {
    local src="$1"
    local dst="$2"
    if [ -f "$src" ]; then
        cp "$src" "$dst"
        echo "-> Copied $(basename "$src")"
    else
        echo "WARNING: missing file: $src"
    fi
}

copy_dir() {
    local src="$1"
    local dst="$2"
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        cp -r "$src"/. "$dst"
        echo "-> Copied $(basename "$src")"
    else
        echo "WARNING: missing dir: $src"
    fi
}

echo "==> [Configs] Applying remaining configs"

mkdir -p "$HOME/.config"

copy_file "$CONFIGS/.gitconfig" "$HOME/.gitconfig"
copy_dir "$CONFIGS/.config/zed" "$HOME/.config/zed"
copy_dir "$CONFIGS/.config/wlogout" "$HOME/.config/wlogout"
copy_dir "$CONFIGS/.config/hyprdynamicmonitors" "$HOME/.config/hyprdynamicmonitors"

echo "==> [Configs] Done"
