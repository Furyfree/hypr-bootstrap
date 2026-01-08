#!/bin/bash

# This script symlinks config files from the repo's 'configs/' directory to the user's home directory.
# It handles both dotfile directories (e.g., .config) and individual dotfiles (e.g., .gitconfig).
# Examples: 
#   configs/.config/btop -> ~/.config/btop
#   configs/.gitconfig -> ~/.gitconfig
# Existing files at the target are backed up with timestamps.
# Run this script from the repo root.

set -euo pipefail

REPO_ROOT=$(pwd)
CONFIG_DIR="$REPO_ROOT/configs"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: 'configs/' directory not found in repo root."
    exit 1
fi

# Handle individual dotfiles at depth 1 (e.g., configs/.gitconfig)
find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 -type f | while read -r item; do
    filename=$(basename "$item")
    
    # Only process dotfiles (those starting with .)
    if [[ "$filename" != .* ]]; then
        continue
    fi
    
    target="$HOME/$filename"
    
    # Backup existing item if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup="$target.bak.$timestamp"
        mv "$target" "$backup"
        echo "Backed up $target to $backup"
    fi
    
    # Create symlink
    ln -sf "$item" "$target"
    echo "Symlinked $item to $target"
done

# Find all directories at depth 2 under configs/ (e.g., configs/.config/btop)
find "$CONFIG_DIR" -mindepth 2 -maxdepth 2 -type d | while read -r item; do
    # Get the relative path after configs/
    rel_path="${item#"$CONFIG_DIR"/}"
    
    # Extract parent (e.g., ".config") and child (e.g., "btop")
    parent=$(dirname "$rel_path")
    child=$(basename "$rel_path")
    
    # Only process dotfile directories (those starting with .)
    if [[ "$parent" != .* ]]; then
        continue
    fi
    
    # Dotfiles go to user's home
    target="$HOME/$parent/$child"
    
    # Ensure parent directory exists
    parent_target=$(dirname "$target")
    mkdir -p "$parent_target"
    
    # Backup existing item if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup="$target.bak.$timestamp"
        mv "$target" "$backup"
        echo "Backed up $target to $backup"
    fi
    
    # Create symlink
    ln -sf "$item" "$target"
    echo "Symlinked $item to $target"
done

echo "Symlinking completed."