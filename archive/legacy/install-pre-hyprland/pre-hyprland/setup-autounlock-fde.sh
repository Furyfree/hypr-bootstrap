#!/bin/bash
set -euo pipefail

echo "Setting up auto unlock of FDE with systemd"

# Authenticate sudo once
sudo -v || exit 1

# Check prerequisites limine-mkinitcpio-hook limine-snapper-sync
if ! pacman -Qi limine-mkinitcpio-hook &>/dev/null; then
  echo "ERROR: limine-mkinitcpio-hook is not installed"
  paru -S limine-mkinitcpio-hook
fi
if ! pacman -Qi limine-snapper-sync &>/dev/null; then
  echo "ERROR: limine-snapper-sync is not installed"
  paru -S limine-snapper-sync
fi

# --- TPM presence check ---
if [ ! -e /dev/tpmrm0 ] && [ ! -e /dev/tpm0 ]; then
  echo "ERROR: No TPM device found"
  exit 1
fi

# --- Determine root mapper ---
ROOT_SRC="$(findmnt -n -o SOURCE /)"
MAPPER_NAME="$(echo "$ROOT_SRC" | sed 's|^/dev/mapper/||; s|\[.*||')"

if [ -z "$MAPPER_NAME" ]; then
  echo "ERROR: Could not determine root mapper"
  exit 1
fi

if ! sudo cryptsetup status "$MAPPER_NAME" >/dev/null 2>&1; then
  echo "ERROR: Root is not a LUKS mapper"
  exit 1
fi

echo "Root mapper: $MAPPER_NAME"

# --- Resolve underlying LUKS device (authoritative) ---
LUKS_DEV="$(sudo cryptsetup status "$MAPPER_NAME" | awk '/device:/ {print $2}')"

if [ -z "$LUKS_DEV" ]; then
  echo "ERROR: Could not resolve LUKS device for root"
  exit 1
fi

echo "Underlying LUKS device: $LUKS_DEV"

# --- Verify LUKS2 ---
if ! sudo cryptsetup luksDump "$LUKS_DEV" | head -n 5 | grep -q "Version:[[:space:]]*2"; then
  echo "ERROR: $LUKS_DEV is not LUKS2"
  exit 1
fi

# --- Get LUKS UUID ---
LUKS_UUID="$(sudo cryptsetup luksUUID "$LUKS_DEV")"

if [ -z "$LUKS_UUID" ]; then
  echo "ERROR: Failed to get LUKS UUID"
  exit 1
fi

echo "LUKS UUID: $LUKS_UUID"

# --- Ensure crypttab.initramfs entry ---
CRYPTTAB="/etc/crypttab.initramfs"
ENTRY="$MAPPER_NAME UUID=$LUKS_UUID - tpm2-device=auto"

sudo touch "$CRYPTTAB"

if grep -q "^$MAPPER_NAME[[:space:]]" "$CRYPTTAB"; then
  if grep -q "^$ENTRY$" "$CRYPTTAB"; then
    echo "crypttab entry already correct"
  else
    echo "ERROR: $MAPPER_NAME entry exists but differs:"
    grep "^$MAPPER_NAME " "$CRYPTTAB"
    exit 1
  fi
else
  echo "Adding crypttab entry"
  echo "$ENTRY" | sudo tee -a "$CRYPTTAB" >/dev/null
fi

# --- Configure mkinitcpio for systemd + sd-encrypt ---
echo "Configuring mkinitcpio (systemd-based initramfs)"

CONF_DIR="/etc/mkinitcpio.conf.d"
CONF_FILE="$CONF_DIR/90-fde-systemd.conf"

sudo mkdir -p "$CONF_DIR"
sudo touch "$CONF_FILE"

sudo tee "$CONF_FILE" >/dev/null <<'EOF'
# systemd-based initramfs for TPM2 auto-unlock
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
EOF

echo "Written $CONF_FILE"

# --- Ensure correct root= in kernel cmdline ---
CMDLINE="/etc/kernel/cmdline"
CMDLINE_DIR="$(dirname "$CMDLINE")"

sudo mkdir -p "$CMDLINE_DIR"
sudo touch "$CMDLINE"

CURRENT_CMDLINE="$(cat "$CMDLINE")"
REQUIRED_ROOT="root=/dev/mapper/$MAPPER_NAME"

if echo "$CURRENT_CMDLINE" | grep -qw "$REQUIRED_ROOT"; then
  echo "Kernel cmdline already has correct root="
elif echo "$CURRENT_CMDLINE" | grep -qw "root="; then
  echo "Fixing existing root= entry"
  NEW_CMDLINE="$(echo "$CURRENT_CMDLINE" | sed "s|root=[^ ]*|$REQUIRED_ROOT|")"
  echo "$NEW_CMDLINE" | sudo tee "$CMDLINE" >/dev/null
else
  echo "Adding missing root= entry"
  echo "$CURRENT_CMDLINE $REQUIRED_ROOT" | sudo tee "$CMDLINE" >/dev/null
fi

# --- Create and store recovery key (idempotent) ---
RECOVERY_FILE="/root/luks-recovery-key.txt"

if sudo cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" | grep -q '"type"[[:space:]]*:[[:space:]]*"systemd-recovery"'; then
  echo "Recovery key already enrolled"
else
  echo "Creating LUKS recovery key"
  sudo systemd-cryptenroll "$LUKS_DEV" --recovery-key | sudo tee $RECOVERY_FILE >/dev/null
  
echo "Recovery key is available in $RECOVERY_FILE"

  # ASSERT: recovery token now exists
  sudo cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" | grep -q '"type"[[:space:]]*:[[:space:]]*"systemd-recovery"'

  sudo chmod 600 $RECOVERY_FILE
fi

# --- Enroll TPM2 auto-unlock (idempotent) ---
if sudo cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" | grep -q '"type"[[:space:]]*:[[:space:]]*"systemd-tpm2"'; then
  echo "TPM2 auto-unlock already enrolled"
else
  echo "Enrolling TPM2 auto-unlock"
  sudo systemd-cryptenroll "$LUKS_DEV" --tpm2-device=auto
fi

# --- Final rebuild ---
echo "Updating bootloader and initramfs"
sudo limine-update

echo "FDE auto-unlock setup complete"