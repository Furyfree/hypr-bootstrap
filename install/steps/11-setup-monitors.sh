#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

log "Setting up hyprdynamicmonitors services..."

systemctl --user daemon-reload
systemctl --user enable --now hyprdynamicmonitors-prepare.service
systemctl --user enable --now hyprdynamicmonitors.service

log "Monitor services configured successfully"
