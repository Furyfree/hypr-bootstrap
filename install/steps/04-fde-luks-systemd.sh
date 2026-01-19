#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

log "Setting up auto unlock of FDE with systemd"

require_sudo
require_paru

# Check prerequisites limine-mkinitcpio-hook limine-snapper-sync
if ! pacman -Qi limine-mkinitcpio-hook &>/dev/null; then
  warn "limine-mkinitcpio-hook is not installed"
  paru -S --noconfirm --needed limine-mkinitcpio-hook
fi
if ! pacman -Qi limine-snapper-sync &>/dev/null; then
  warn "limine-snapper-sync is not installed"
  paru -S --noconfirm --needed limine-snapper-sync
fi

# --- TPM presence check ---
if [ ! -e /dev/tpmrm0 ] && [ ! -e /dev/tpm0 ]; then
  die "No TPM device found"
fi

# --- Determine root mapper ---
ROOT_SRC="$(findmnt -n -o SOURCE /)"
MAPPER_NAME="$(echo "$ROOT_SRC" | sed 's|^/dev/mapper/||; s|\[.*||')"

if [ -z "$MAPPER_NAME" ]; then
  die "Could not determine root mapper"
fi

if ! sudo cryptsetup status "$MAPPER_NAME" >/dev/null 2>&1; then
  die "Root is not a LUKS mapper"
fi

log "Root mapper: $MAPPER_NAME"

# --- Resolve underlying LUKS device (authoritative) ---
LUKS_DEV="$(sudo cryptsetup status "$MAPPER_NAME" | awk '/device:/ {print $2}')"

if [ -z "$LUKS_DEV" ]; then
  die "Could not resolve LUKS device for root"
fi

log "Underlying LUKS device: $LUKS_DEV"

# --- Verify LUKS2 ---
if ! sudo cryptsetup luksDump "$LUKS_DEV" | head -n 5 | grep -q "Version:[[:space:]]*2"; then
  die "$LUKS_DEV is not LUKS2"
fi

# --- Get LUKS UUID ---
LUKS_UUID="$(sudo cryptsetup luksUUID "$LUKS_DEV")"

if [ -z "$LUKS_UUID" ]; then
  die "Failed to get LUKS UUID"
fi

log "LUKS UUID: $LUKS_UUID"

# --- Ensure crypttab.initramfs entry ---
CRYPTTAB="/etc/crypttab.initramfs"
ENTRY="$MAPPER_NAME UUID=$LUKS_UUID - tpm2-device=auto"

sudo touch "$CRYPTTAB"

if grep -q "^$MAPPER_NAME[[:space:]]" "$CRYPTTAB"; then
  if grep -q "^$ENTRY$" "$CRYPTTAB"; then
    log "crypttab entry already correct"
  else
    warn "$MAPPER_NAME entry exists but differs:"
    grep "^$MAPPER_NAME " "$CRYPTTAB"
    exit 1
  fi
else
  log "Adding crypttab entry"
  echo "$ENTRY" | sudo tee -a "$CRYPTTAB" >/dev/null
fi

# --- Configure mkinitcpio for systemd + sd-encrypt ---
log "Configuring mkinitcpio (systemd-based initramfs)"

CONF_DIR="/etc/mkinitcpio.conf.d"
CONF_FILE="$CONF_DIR/fde-systemd.conf"

sudo mkdir -p "$CONF_DIR"
sudo touch "$CONF_FILE"

sudo tee "$CONF_FILE" >/dev/null <<'EOF'
# systemd-based initramfs for TPM2 auto-unlock
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
EOF

# Move omarchy hook file to .bak
if [ -f /etc/mkinitcpio.conf.d/omarchy_hooks.conf ]; then
  sudo mv /etc/mkinitcpio.conf.d/omarchy_hooks.conf /etc/mkinitcpio.conf.d/omarchy_hooks.conf.bak
fi

log "Written $CONF_FILE"
# --- Ensure correct root= in kernel cmdline ---
CMDLINE="/etc/kernel/cmdline"
CMDLINE_DIR="$(dirname "$CMDLINE")"

sudo mkdir -p "$CMDLINE_DIR"
sudo touch "$CMDLINE"

CURRENT_CMDLINE="$(cat "$CMDLINE")"
REQUIRED_ROOT="root=/dev/mapper/$MAPPER_NAME"

if echo "$CURRENT_CMDLINE" | grep -qw "$REQUIRED_ROOT"; then
  log "Kernel cmdline already has correct root="
elif echo "$CURRENT_CMDLINE" | grep -qw "root="; then
  log "Fixing existing root= entry"
  NEW_CMDLINE="$(echo "$CURRENT_CMDLINE" | sed "s|root=[^ ]*|$REQUIRED_ROOT|")"
  echo "$NEW_CMDLINE" | sudo tee "$CMDLINE" >/dev/null
else
  log "Adding missing root= entry"
  echo "$CURRENT_CMDLINE $REQUIRED_ROOT" | sudo tee "$CMDLINE" >/dev/null
fi

# --- Create and store recovery key (idempotent) ---
RECOVERY_FILE="/root/luks-recovery-key.txt"

read_passphrase() {
  if [ -n "${LUKS_PASSPHRASE:-}" ]; then
    printf '%s' "$LUKS_PASSPHRASE"
    return 0
  fi
  if [ ! -t 0 ]; then
    warn "No TTY available for passphrase prompt."
    warn "Run: sudo systemd-tty-ask-password-agent"
    return 1
  fi
  systemd-ask-password "Enter current LUKS passphrase for $LUKS_DEV:"
}

if sudo cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" | grep -q '"type"[[:space:]]*:[[:space:]]*"systemd-recovery"'; then
  log "Recovery key already enrolled"
else
  log "Creating LUKS recovery key"
  PASSPHRASE="$(read_passphrase)"
  printf '%s\n' "$PASSPHRASE" | sudo systemd-cryptenroll "$LUKS_DEV" --recovery-key --password-file=- | sudo tee "$RECOVERY_FILE" >/dev/null

  log "Recovery key is available in $RECOVERY_FILE"

  # ASSERT: recovery token now exists
  sudo cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" | grep -q '"type"[[:space:]]*:[[:space:]]*"systemd-recovery"'

  sudo chmod 600 $RECOVERY_FILE
fi

# --- Enroll TPM2 auto-unlock (idempotent) ---
if sudo cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" | grep -q '"type"[[:space:]]*:[[:space:]]*"systemd-tpm2"'; then
  log "TPM2 auto-unlock already enrolled"
else
  log "Enrolling TPM2 auto-unlock"
  if [ -z "${PASSPHRASE:-}" ]; then
    PASSPHRASE="$(read_passphrase)"
  fi
  printf '%s\n' "$PASSPHRASE" | sudo systemd-cryptenroll "$LUKS_DEV" --tpm2-device=auto --password-file=-
fi

# --- Final rebuild ---
log "Updating bootloader and initramfs"
sudo limine-update

log "FDE auto-unlock setup complete"
unset PASSPHRASE
