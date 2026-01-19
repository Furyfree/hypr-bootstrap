#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# This script symlinks config files from the repo's 'configs/' directory to the user's home directory.
# It handles both dotfile directories (e.g., .config) and individual dotfiles (e.g., .gitconfig).
# Examples:
#   configs/.config/btop -> ~/.config/btop
#   configs/.gitconfig -> ~/.gitconfig
# Existing files at the target are backed up with timestamps.

CONFIG_DIR="$REPO_ROOT/configs"
BACKUP_DIR="$HOME/.config/backups"

# Create backups directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

if [ ! -d "$CONFIG_DIR" ]; then
    die "configs/ directory not found in repo root"
fi

# Handle individual dotfiles at depth 1 (e.g., configs/.gitconfig)
find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 -type f | while read -r item; do
    filename=$(basename "$item")

    # Only process dotfiles (those starting with .)
    if [[ "$filename" != .* ]]; then
        continue
    fi

    target="$HOME/$filename"

    # Backup existing item if it exists and is not already a symlink to our repo
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Skip if it's already a symlink pointing to our configs
        if [ -L "$target" ]; then
            link_target=$(readlink "$target")
            if [[ "$link_target" == "$CONFIG_DIR"* ]]; then
                log "Skipping $target (already symlinked to repo)"
                continue
            fi
        fi
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup="$BACKUP_DIR/$filename.bak.$timestamp"
        mv "$target" "$backup"
        log "Backed up $target to $backup"
    fi

    # Create symlink
    ln -sf "$item" "$target"
    log "Symlinked $item to $target"
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

    # Backup existing item if it exists and is not already a symlink to our repo
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Skip if it's already a symlink pointing to our configs
        if [ -L "$target" ]; then
            link_target=$(readlink "$target")
            if [[ "$link_target" == "$CONFIG_DIR"* ]]; then
                log "Skipping $target (already symlinked to repo)"
                continue
            fi
        fi
        timestamp=$(date +%Y%m%d_%H%M%S)
        # Preserve directory structure in backups
        backup_rel_path="$parent/$child.bak.$timestamp"
        backup="$BACKUP_DIR/$backup_rel_path"
        mkdir -p "$(dirname "$backup")"
        mv "$target" "$backup"
        log "Backed up $target to $backup"
    fi

    # Create symlink
    ln -sf "$item" "$target"
    log "Symlinked $item to $target"
done

log "Symlinking completed."
