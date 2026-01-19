#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_sudo

if pacman -Qi code-features &>/dev/null; then
    log "Updating code-features patch..."
    sudo code-features-update --system
fi

if pacman -Qi code-marketplace &>/dev/null; then
    log "Updating code-marketplace patch..."
    sudo code-marketplace-update --system
fi

log "Setup complete. Restart VS Code, then install GitHub Copilot extensions and sign in."
