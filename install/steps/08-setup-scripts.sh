#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

SCRIPTS_SOURCE="$REPO_ROOT/scripts"
TARGET_DIR="$HOME/.local/bin"
TARGET_LINK="$TARGET_DIR/scripts"

if [[ ! -d "$SCRIPTS_SOURCE" ]]; then
    die "Scripts directory not found at $SCRIPTS_SOURCE"
fi

mkdir -p "$TARGET_DIR"

ln -sfn "$SCRIPTS_SOURCE" "$TARGET_LINK"

shopt -s nullglob
for script in "$SCRIPTS_SOURCE"/*; do
    if [[ -f "$script" ]]; then
        name=$(basename "$script")
        ln -sf "$script" "$TARGET_DIR/$name"
        log "Linked $name"
    fi
done
shopt -u nullglob

if [[ ":${PATH}:" != *":${TARGET_DIR}:"* ]]; then
    log "Note: $TARGET_DIR is not in your PATH. Add: export PATH=\"$TARGET_DIR:\$PATH\""
fi

log "Script setup complete."
