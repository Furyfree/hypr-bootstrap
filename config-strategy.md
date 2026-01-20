# Config + App Strategy (HyprDK)

This document recommends whether each config should be stubbed, copied, or symlinked when moving the repo to `~/.local/share/hyprdk`.

Legend:
- Stub: a tiny file in `~/.config` (or `$HOME`) that sources/includes repo config.
- Copy: full config copied into place once (no automatic updates).
- Symlink: live link to repo config (auto-updates when repo changes).
- Wrapper: a launcher/alias/env var points the app to repo config.

## Recommended by Area

### Dotfiles
- `~/.zshrc`: Stub (sources repo `configs/.config/zsh/*.zsh`).
- `~/.gitconfig`: Stub using `[include]` (Git supports includes).

### Hyprland
- `~/.config/hypr/hyprland.conf`: Stub.
  - Note: runtime files like `monitors.conf` and `colors.conf` are generated in `~/.config`. The stub should source those from `~/.config` and the rest from the repo.
- Other `hypr/*.conf`: keep in repo and referenced by stub.

### Waybar
- `~/.config/waybar/config.jsonc`: Stub with `include` pointing at repo modules.
- `~/.config/waybar/style.css`: Stub with `@import` to repo style (or symlink).
- `~/.config/waybar/scripts/*`: keep in repo; module config should call scripts via absolute repo paths.

### Ghostty
- `~/.config/ghostty/config`: Stub with `config-file = ~/.local/share/hyprdk/configs/.config/ghostty/config`.
- `ghostty/keybindings` and `ghostty/themes/*`: keep in repo and referenced by the included config.
- Verify: ensure `config-file` resolves relative includes (if not, use symlink).

### Matugen
- `~/.config/matugen/config.toml` and `templates/*`:
  - Best: Wrapper (run `matugen -c <repo config>` in scripts) or symlink.
  - Copy only if you accept manual updates.

### Hyprdynamicmonitors
- `~/.config/hyprdynamicmonitors/config.toml`:
  - Best: Wrapper if CLI supports `--config` (point to repo) or symlink.
  - Otherwise copy.

### Btop
- `~/.config/btop/btop.conf` and themes:
  - Best: Wrapper/alias (`btop --config <repo>`) or symlink.
  - Otherwise copy.

### Walker
- `~/.config/walker/config.toml`, `layout.xml`, `themes/*`:
  - Best: Wrapper if config path can be specified, or symlink.
  - Otherwise copy.

### Udiskie
- `~/.config/udiskie/config.yml`:
  - Best: update autostart to `udiskie --config <repo>` (wrapper).
  - Otherwise copy or symlink.

### Zed
- `~/.config/zed/settings.json` and `keymap.json`:
  - Copy or symlink (no include support known).

### GTK
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/gtk-4.0/settings.ini`
  - Copy (INI files do not support include).
  - Alternatively omit if gsettings is the source of truth.

### Bluetui
- `~/.config/bluetui/config.toml`: Copy or symlink (no include support known).

### Fontconfig
- `~/.config/fontconfig/fonts.conf`: Stub using `<include>` to repo config (fontconfig supports include).

### Mise
- `~/.config/mise/config.toml`:
  - Best: set `MISE_CONFIG_FILE` in zsh to repo path.
  - Otherwise copy or symlink.

### Starship
- Use `STARSHIP_CONFIG` env to point at repo config (no stub needed if env is set in zsh).

### Themeswitcher
- `~/.config/themeswitcher/themeswitcher`: Copy or symlink (needs verification).

### Apps (.desktop) and icons
- `~/.local/share/applications/*.desktop`: Copy (current approach).
- `~/.local/share/icons/*`: Copy (current approach).
- Symlink only if you want live updates to desktop entries/icons.

## Tracking Recommendation
Maintain a small `config-map.md` with columns:
`app | target path | method (stub/copy/symlink/wrapper) | notes`.

## Open Questions
- Ghostty: confirm how `config-file` resolves relative paths.
- Walker/udiskie/hyprdynamicmonitors: confirm CLI flags for config path.
- Matugen: decide whether outputs live in `~/.config` or the repo.
- GTK: decide whether settings.ini is needed if gsettings is authoritative.
