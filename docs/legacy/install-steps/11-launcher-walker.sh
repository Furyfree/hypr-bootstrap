#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

require_cmd walker

log "Enabling walker service..."
systemctl --user daemon-reload
systemctl --user enable --now walker.service

log "Walker service enabled."
