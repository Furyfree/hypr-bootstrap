# hypr-bootstrap
Personal Hyprland setup for Arch Linux, focused on a clean base and reproducible installs.

## Quick start
### From a local clone
```bash
git clone git@github.com:Furyfree/hypr-bootstrap.git ~/git/hypr-bootstrap
cd ~/git/hypr-bootstrap
./install.sh
```

### Bootstrap (no repo yet)
```bash
curl -fsSL https://raw.githubusercontent.com/Furyfree/hypr-bootstrap/main/bootstrap.sh | bash
```

Environment overrides for bootstrap:
- `HYPR_BOOTSTRAP_REPO` (default: `https://github.com/Furyfree/hypr-bootstrap.git`)
- `HYPR_BOOTSTRAP_DIR` (default: `~/git/hypr-bootstrap`)
- `HYPR_BOOTSTRAP_REF` (optional: branch/tag/commit)

## Repo layout
- `install.sh`: orchestrates the canonical steps in `install/steps/`.
- `install/base.packages` and `install/aur.packages`: package sources used by `install/steps/02-install-apps.sh`.
- `configs/`: dotfiles, system config fragments, and `.desktop` entries.
- `scripts/`: user helpers symlinked into `~/.local/bin`.
- `docs/legacy/`: archived notes and old scripts.
