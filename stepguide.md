# Step for step guide

## 1. Create arch boot media

## 2. Boot into Arch live iso

## 3. Setup before Archinstall

loadkeys dk
iwctl (for wifi)

## 4. Archinstall

Run through Archinstall

## 5. Fix sudo

Login in as root (`su`)

```
usermod -aG wheel youruser
EDITOR=nano visudo
```

uncomment:

```
# %wheel ALL=(ALL:ALL) ALL
```

Log out and log in, then confirm with:

```
sudo whoami
```

Expected output:

```
root
```

## 6. Setup wifi again

```
setfont -d
sudo systemctl enable --now NetworkManager iwd
nmcli general status
nmcli device wifi list
nmcli device wifi connect "SSID_NAME" --ask
```

## 7. Setup ssh quickly

```
sudo pacman -S openssh
sudo systemctl enable --now sshd
```

## 8. Install Paru
```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

## 9. Install Limine helpers
```
paru -S --noconfirm --needed limine-snapper-sync limine-mkinitcpio-hook
```

## 9. Setup FDE systemd-cryptenroll for auto unlock

Change `/etc/mkinitcpio.conf`:

```
##   This will create a systemd based initramfs which loads an encrypted root filesystem.
#    HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole sd-encrypt block filesystems fsck)
#
##   NOTE: If you have /usr on a separate partition, you MUST include the
#    usr and fsck hooks.
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

To

```
##   This will create a systemd based initramfs which loads an encrypted root filesystem.
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole sd-encrypt block filesystems fsck)
#
##   NOTE: If you have /usr on a separate partition, you MUST include the
#    usr and fsck hooks.
#    HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

and regenerate initramfs:

```
sudo mkinitcpio -P
```

Now enroll with correct disk and write FDE password:

```
sudo systemd-cryptenroll /dev/nvme0n1p2 --tpm2-device=auto
```





New luks steps:
```
# Check TPM exists
ls -l /dev/tpm* /sys/class/tpm/ 2>/dev/null

# Check LUKS version
sudo cryptsetup luksDump /dev/nvme0n1p2 | head

# Get LUKS ID
sudo cryptsetup luksUUID /dev/nvme0n1p2

# Add LUKS ID to crypttab
sudo EDITOR=nano sudoedit /etc/crypttab.initramfs
# Insert
root UUID=<LUKSID> - tpm2-device=auto

# Edit `/etc/mkinitcpio.conf` from udev to systemd
sudo nano /etc/mkinitcpio.conf

# From this
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)

# To this and add sd-btrfs-overlayfs to the line so it looks like this beneath
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole sd-encrypt block sd-btrfs-overlayfs filesystems fsck)

# Make boot entry correct always
sudo nano /etc/kernel/cmdline
# add this
root=/dev/mapper/root rw rootfstype=btrfs rootflags=subvol=@ zswap.enabled=0

# Rebuild initramfs again
sudo limine-update

# Create recovery key and save it
sudo systemd-cryptenroll /dev/nvme0n1p2 --recovery-key

# Make auto unlock encryption
sudo systemd-cryptenroll /dev/nvme0n1p2 --tpm2-device=auto
```



ivdlnike-kktiunet-felkdnue-glfhernn-flljfceg-cvludjtu-ibfbbufh-tighvuie