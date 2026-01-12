#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Expected location of the scripts folder (two levels up in your repo structure)
SCRIPTS_SOURCE="${SCRIPT_DIR}/../../scripts"

TARGET_LINK="${HOME}/.local/bin/scripts"

if [[ ! -d "$SCRIPTS_SOURCE" ]]; then
    echo "Error: Scripts directory not found at $SCRIPTS_SOURCE"
    echo "Check your repo structure."
    exit 1
fi

mkdir -p "${HOME}/.local/bin"

# Remove old symlink if it exists and is wrong
if [[ -L "$TARGET_LINK" ]]; then
    if [[ "$(readlink -f "$TARGET_LINK")" != "$(realpath "$SCRIPTS_SOURCE")" ]]; then
        rm -f "$TARGET_LINK"
    else
        echo "Symlink already correct. Nothing to do."
        exit 0
    fi
elif [[ -e "$TARGET_LINK" ]]; then
    echo "Error: $TARGET_LINK exists but is not a symlink."
    echo "Remove or rename it manually first."
    exit 1
fi

ln -sf "$SCRIPTS_SOURCE" "$TARGET_LINK"

echo "Symlinked $SCRIPTS_SOURCE → $TARGET_LINK"

# Quick PATH reminder (only shown if needed)
if [[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]]; then
    echo
    echo "Note: ~/.local/bin is not in your PATH."
    echo "Add this to ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "Then run: source ~/.bashrc"
fi

echo "Done."