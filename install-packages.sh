#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/packages.txt"

# Read packages, skip comments (#) and empty lines
PACKAGES=$(grep -v '^\s*#' "$PACKAGES_FILE" | grep -v '^\s*$')

paru -S --needed --noconfirm $PACKAGES
