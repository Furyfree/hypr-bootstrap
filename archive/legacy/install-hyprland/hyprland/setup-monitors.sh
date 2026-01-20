#!/bin/bash
set -euo pipefail

echo "Setting up hyprdynamicmonitors services..."

# Enable and start both services
systemctl --user enable --now hyprdynamicmonitors-prepare.service
systemctl --user enable --now hyprdynamicmonitors.service

echo "Monitor services configured successfully"