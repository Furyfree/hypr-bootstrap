#!/bin/bash
set -euo pipefail

# Update the proposed APIs / features patch to match the latest official VS Code
echo "Updating code-features patch..."
sudo code-features-update --system

# Optional: ensure the marketplace patch is also up-to-date
# (only needed if you use code-marketplace from chaotic-aur)
if pacman -Qi code-marketplace &>/dev/null; then
    echo "Updating code-marketplace patch..."
    sudo code-marketplace-update --system
fi

# Remind the user to restart VS Code
echo ""
echo "========================================"
echo "Setup complete!"
echo "Now close all VS Code windows and restart it."
echo "Then:"
echo "  • Install 'GitHub Copilot' and 'GitHub Copilot Chat' from the Extensions view"
echo "  • Sign in with your GitHub account when prompted"
echo "========================================"