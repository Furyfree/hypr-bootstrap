#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Hide desktop entries
echo "--> Backing up unwanted desktop entries"
# List of entries to disable
for filename in \
    "Basecamp.desktop" \
    "Figma.desktop" \
    "Fizzy.desktop" \
    "Google Contacts.desktop" \
    "Google Messages.desktop" \
    "Google Photos.desktop" \
    "HEY.desktop"
do
    f="$HOME/.local/share/applications/$filename"
    if [ -e "$f" ]; then
        mv "$f" "$f.bak"
        echo "    -> backed up $filename"
    fi
done

APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$APP_DIR" "$ICON_DIR"

shopt -s nullglob
desktop_files=("$REPO_ROOT/desktop-entries/applications/"*.desktop)
icon_files=("$REPO_ROOT/desktop-entries/icons/"*)
shopt -u nullglob

if [ "${#desktop_files[@]}" -gt 0 ]; then
    cp -f "${desktop_files[@]}" "$APP_DIR/"
else
    echo "--> No desktop entries found in $REPO_ROOT/applications"
fi

if [ "${#icon_files[@]}" -gt 0 ]; then
    cp -f "${icon_files[@]}" "$ICON_DIR/"
else
    echo "--> No icons found in $REPO_ROOT/applications/icons"
fi
