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

## 8. Setup FDE systemd-cryptenroll for auto unlock

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
