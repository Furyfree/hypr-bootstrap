# AGENTS.md

Quick, practical map for working in this repo.

## What this project is

- Hyprland bootstrap for Arch Linux: automated install scripts plus repo-managed configs and app confirming for a reproducible desktop.

## Entry points

- `bootstrap.sh`: clones the repo into `~/git` and runs `install.sh` (for machines without the repo).
- `install.sh`: main pipeline; runs the canonical scripts in `install/steps/`.
- `install/steps/`: ordered install steps (AUR, packages, FDE, configs, services).
- `install/base.packages` + `install/aur.packages`: package sources for `install/steps/02-install-apps.sh`.
- `install/lib/common.sh`: shared helpers for install scripts.
- `configs/`: dotfiles, app launchers, and system config fragments.
- `scripts/`: user-facing helpers that get symlinked into `~/.local/bin` (and `~/.local/bin/scripts`).

## Config layout

- `configs/.config/`: Hyprland, Waybar, Walker, matugen, wlogout, zsh modules, etc.
- `configs/applications/`: `.desktop` entries and icons copied to `~/.local/share/applications` and `~/.local/share/icons`.
- `configs/etc/ly/`: login manager config for ly.
- `configs/.gitconfig`, `configs/.zshrc`: top-level dotfiles symlinked to `$HOME`.

## Legacy

- Older install scripts and docs are archived under `docs/legacy/`.

## Common tasks

- Update dotfiles: edit under `configs/`, then run `install/steps/06-install-configs.sh`.
- Install app launchers/icons: run `install/steps/09-setup-apps.sh`.
- Install helper scripts: run `install/steps/08-setup-scripts.sh` and ensure `~/.local/bin` is in PATH.
  - Walker autostarts via Hyprland config (`configs/.config/hypr/autostart.conf`), not a systemd step.

## Docs to consult

- `README.md`: short overview.
- `docs/legacy/`: older summaries and notes (may be outdated).
