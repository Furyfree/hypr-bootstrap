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
sudo pacman -S rustup
rustup default stable
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

## 9. Install Limine helpers
```
paru -S --noconfirm --needed limine-snapper-sync limine-mkinitcpio-hook
```

## 10. Setup LUKS auto unlock
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







Setup greetd and regreet
```
[pby@archbook ~]$ cat /etc/greetd/config.toml
[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 1

# The default session, also known as the greeter.
[default_session]

# `agreety` is the bundled agetty/login-lookalike. You can replace `/bin/sh`
# with whatever you want started, such as `sway`.
# command = "Hyprland --config /etc/greetd/hyprland.conf"

command = "start-hyprland -- -c /etc/greetd/hyprland.conf"

# command = "agreety --cmd /bin/sh"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the `video` group.
user = "greeter"
[pby@archbook ~]$ cat /etc/greetd/hyprland.conf
exec-once = regreet; hyprctl dispatch exit
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    disable_hyprland_guiutils_check = true
}

env = GTK_USE_PORTAL,0
env = GDK_DEBUG,no-portals

[pby@archbook ~]$
sudo systemctl start greetd.service
```