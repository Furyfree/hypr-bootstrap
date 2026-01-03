# Plan

## Archinstall

Use Archinstall:

- Locales:
  - Keyboard layout: dk
  - unchanged
  - unchanged
- Mirrors and repositories
  - Denmark
  - Worldwide
- Partitioning
- Swap
  - Enabled
- Bootloader
  - Limine
  - Unified kernel images: Disabled
  - Install to removable location: No
- Hostname
  - archbook
  - archtop
- Authentication
  - user (no su and no root password)
- Profile
  - Minimal
- Applications
  - Bluetooth
    - Enabled
  - Audio
    - Pipewire
  - Print service
    - Yes if its there
  - Power management
    - power-profiles-daemon
- Kernels
  - linux-zen
  - linux-lts or linux (maybe needed as backup)
- Network configuration
  - Use Network Manager (iwd backend)
- Additional packages
  - git
  - iwd
  - nano / vim / neovim
- Timezone
  - Europe/Copenhagen
- Automatic time sync (NTP)
  - Enabled

## Design idea

Kinda a MacOS aestethic where it's minimal but still clean looking with seethrough (not completely liquid glass).

When possible, install via pacman or else use AUR. If useable as a webapp, make webapp for it.

Workspaces should be for apps whereas special workspaces should be for "always" open apps like (Signal,
Messenger, Spotify and others)

AUR vs Chaotic-AUR rule

This rule of thumb is good and pragmatic. The only correction:

- Core system + important tools: official repos first, then AUR if needed
- Heavy apps you reinstall often: Chaotic-AUR

The sweet spot is micro-animations that:

- are fast enough you don’t consciously notice them
- exist only to confirm state changes

Make border inline without outmost icon in waybar
https://github.com/Alexays/Waybar/wiki

Use propo fonts for waybar css

Make ~/.config/matugen/templates to save all matugen templates for different apps (ghostty, gtk, colors.css, )
https://github.com/InioX/matugen-themes/tree/main/templates
check how to refresh terminals and apps
add post_hook in config.toml and add different modules
source into the configs you have included in config.toml

Use startpage for search engine

So for changing themes its mainly sww img PATHTOIMAGE and matugen image PATHTOIMAGE

pkill launcher || $launcher

## Hyprland stack

- Waybar
  - Workspaces
  - Day and time / Date, week and year
  - Tray
  - Bluetooth
  - Audio
  - Wifi
  - Btop
  - Updates
  - Walker menu
  - Notifications
  - Battery (if on battery) (powerprofiles-daemon - https://gitlab.gnome.org/Infrastructure/Mirrors/lorry-mirrors/gitlab_freedesktop_org/hadess/power-profiles-daemon)
  - Weather
- Walker
  - Launch apps
  - Change theme
  - Change background
- Impala
- Wiremix
- Bluetui
- SwayNotificationCenter
- Paru

### Extras

- xdg-desktop-portal-hyprland
- polkit-gnome (maybe hyprpolkitagent later)
- qt5-wayland
- qt6-wayland
- nwg-look
- kvantum
- kvantum-qt5
- udiskie
- matugen (python-pywal16 is old)
- hypridle
- hyprlock (MacOS Themed)
- xdg-user-dirs
- xdg-utils
- hyprpicker (maybe)
- hyprsunset
- hyprsysteminfo (maybe)
- hyprshutdown (maybe instead of Wlogout as hyprshutdown is not stable)
- hyprtoolkit (maybe)
- pacman-contrib

## Wallpapers

- Swww (now awww)
- Hyprpaper

## Fonts and theme

- Terminal: JetBrainsMono Nerd Font
- Waybar:
  - text: SF Pro Text
  - icons/modules: JetBrainsMono Nerd Font
- GTK/Qt: SF Pro Text
- Papirus folders and icon theme
- MacOS cursor

## Themes

- Catppuccin
- Nord
- Everforrest
- GitHub Dark Theme
- Tokyo Night
- Kanagawa
- One Dark (Pro)

## Login flow

- Limine bootloader (limine-snapper-restore)
- FDE (autounlock)
- greetd and regreet (MacOS themed)

## Network stack

- NetworkManager + IWD

## Applications

### File managers

- Thunar
- Yazi

### Editors

- VS Codium – ecosystem editor
- JetBrains - full IDEs. Best for large/enterprise codebases, refactors, debugging
- Neovim – fast terminal editor
- Cursor – AI-first prototyping
- Zed – modern general editor

#### Style

- Left side
  - Explorer
  - Git
- Right side
  - Agent (AI)
- Bottom
  - Terminal
    Git tree (Only Jetbrains)

### Terminal

- Ghostty
  - Themed (Theme switcher)
  - Starship
  - zsh
    - Multiple zsh files for different purposes (modulising)
  - Zinit
  - Zoxide
  - Fuzzy-find
  - JetBrainsMono Nerd Font

### Browsers

- Helium (winner) -
- Zen
- Librewolf
- Chromium
- Firefox

#### Extensions

- uBlock
- 1Password
- Darkreader
- BookmarkHub
- Proton VPN

### General apps

- 1Password
- Numi Calculator (CLI until app comes to Linux) - Maybe gnome calc for now
- Discord
- Docker (Lazydocker)
- Libreoffice
- OBS
- Obsidian
- Signal
- Spotify (AUR)
- Disk usage (Baobab or Dust)
- Kdenlive
- Media Player (mpv)
- Image Viewer (Loupe or imv)
- Print Settings (https://www.siberoloji.com/how-to-set-up-a-printer-with-cups-on-arch-linux/)
- drawio-desktop
- Pinta
- Gimp

### Webapps

- ChatGPT
- Fastmail
- Messenger
- Notebook LM

### CLI

- Btop
- zsh
- Neovim
- Fastfetch
- Dust
- fd
- Yazi
- duf
- ripgrep
- fzf
- lazygit
- lazydocker
- gh
- tldr
- Zoxide
- bat
- curlie
- httpie
- bandwhich

### Gaming

- Steam
- Faugus Launcher
  - Battlenet
    - World of Warcraft
      - WagoApp
      - Wowup
- Minecraft

## Postinstall

### Wheel and sudo

- Tjek groups for wheel og tilføj bruger til wheel, efter kør EDITOR=<editor> visudo, udkommenter:
  - %wheel...
  - %sudo
