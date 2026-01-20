# Config Map

`app | target path | method | notes`

## Dotfiles
- zsh | ~/.zshrc | stub | Stub points to repo main file, which sources modules.
- git | ~/.gitconfig | TBD (stub or copy) | File is minimal; decide if include is worth it.

## Hyprland
- hyprland | ~/.config/hypr/hyprland.conf | stub | Stub includes repo hypr configs + runtime files in ~/.config.
- hyprland | ~/.config/hypr/*.conf | repo | Referenced by stub; keep in repo.
- hyprdynamicmonitors | ~/.config/hypr/monitors.conf | runtime | Generated in ~/.config.

## Waybar
- waybar | ~/.config/waybar/config.jsonc | stub | Stub includes repo module JSONC.
- waybar | ~/.config/waybar/style.css | stub or copy | Stub can `@import` repo CSS; copy if preferred.
- waybar scripts | ~/.config/waybar/scripts/* | repo | Module config should call scripts via repo path.

## Ghostty
- ghostty | ~/.config/ghostty/config | stub | Use `config-file` to point at repo config.
- ghostty | ~/.config/ghostty/keybindings | repo | Referenced by config.
- ghostty | ~/.config/ghostty/themes/* | repo | Referenced by config.

## Matugen
- matugen | ~/.config/matugen/config.toml | wrapper | Use wrapper invoking `matugen -c <repo>`.
- matugen | ~/.config/matugen/templates/* | repo | Used by matugen config.

## Hyprdynamicmonitors
- hdm | ~/.config/hyprdynamicmonitors/config.toml | none (runtime) | Let the app generate per-machine config; no repo-managed file.

## Btop
- btop | ~/.config/btop/btop.conf | wrapper | Use `btop --config <repo>` if supported.
- btop themes | ~/.config/btop/themes/* | repo | Referenced by config; matugen may write to ~/.config.

## Walker
- walker | ~/.config/walker/config.toml | TBD | Needs decision after capability check.
- walker | ~/.config/walker/layout.xml | TBD | Depends on config location decision.
- walker themes | ~/.config/walker/themes/* | TBD | Depends on config location decision.

## Udiskie
- udiskie | ~/.config/udiskie/config.yml | wrapper | Prefer `udiskie --config <repo>`.

## Zed
- zed | ~/.config/zed/settings.json | symlink | No include support known.
- zed | ~/.config/zed/keymap.json | symlink | No include support known.

## GTK
- gtk3 | ~/.config/gtk-3.0/settings.ini | copy | INI has no include support.
- gtk4 | ~/.config/gtk-4.0/settings.ini | copy | INI has no include support.

## Bluetui
- bluetui | ~/.config/bluetui/config.toml | TBD (copy or symlink) | Optional; may be unnecessary.

## Fontconfig
- fontconfig | ~/.config/fontconfig/fonts.conf | stub | Use `<include>` to repo file.

## Mise
- mise | ~/.config/mise/config.toml | wrapper if possible | Prefer `MISE_CONFIG_FILE`; fallback to copy/symlink.

## Starship
- starship | ~/.config/starship/starship.toml | wrapper | Set `STARSHIP_CONFIG` to repo path.

## Themeswitcher
- themeswitcher | ~/.config/themeswitcher/themeswitcher | stub | Stub sources repo script.

## Apps and Icons
- desktop entries | ~/.local/share/applications/*.desktop | copy | Keep current copy approach.
- icons | ~/.local/share/icons/* | copy | Keep current copy approach.

## Notes
- “repo” means the canonical file lives in `~/.local/share/hyprdk/configs/...` and is referenced by a stub or wrapper.
- “wrapper” means an alias/script sets the config path (no stub needed).
