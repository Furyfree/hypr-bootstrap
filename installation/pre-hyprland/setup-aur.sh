#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"

echo "Installing prerequisites for paru"

sudo pacman -Sy --needed --noconfirm \
  base-devel \
  git \
  rustup

echo "Initializing rustup"
rustup default stable

if command -v paru >/dev/null 2>&1; then
  echo "paru already installed, skipping"
  exit 0
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "Cloning paru"
git clone https://aur.archlinux.org/paru.git "$WORKDIR/paru"

echo "Building and installing paru"
cd "$WORKDIR/paru"
makepkg -si --noconfirm

echo "paru installation complete"