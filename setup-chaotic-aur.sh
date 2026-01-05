#!/bin/bash
set -euo pipefail

echo "Setting up Chaotic-AUR"

CHAOTIC_KEY="3056513887B78AEB"

# Check if already configured
if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
  echo "Chaotic-AUR already configured in pacman.conf, skipping"
  exit 0
fi

# Receive and sign key if not already trusted
if ! pacman-key --list-keys "$CHAOTIC_KEY" &>/dev/null; then
  echo "Receiving Chaotic-AUR key"
  sudo pacman-key --recv-key "$CHAOTIC_KEY" --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key "$CHAOTIC_KEY"
else
  echo "Chaotic-AUR key already trusted"
fi

# Install keyring if not present
if ! pacman -Qi chaotic-keyring &>/dev/null; then
  echo "Installing chaotic-keyring"
  sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
else
  echo "chaotic-keyring already installed"
fi

# Install mirrorlist if not present
if ! pacman -Qi chaotic-mirrorlist &>/dev/null; then
  echo "Installing chaotic-mirrorlist"
  sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
else
  echo "chaotic-mirrorlist already installed"
fi

# Write complete pacman.conf
echo "Writing pacman.conf with Chaotic-AUR"
sudo tee /etc/pacman.conf >/dev/null <<'EOF'
# See the pacman.conf(5) manpage for option and repository directives

[options]
Color
ILoveCandy
VerbosePkgLists
HoldPkg = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 5
DownloadUser = alpm

# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional

# pacman searches repositories in the order defined here
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

# Sync databases
sudo pacman -Sy

echo "Chaotic-AUR setup complete"
