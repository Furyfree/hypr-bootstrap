# HyprDK Restructure Plan

## Goals
- Move the canonical repo to `~/.local/share/hyprdk`.
- Keep `~/.config` minimal via stubs only (no symlinks).
- Never overwrite existing stubs once installed.
- Provide clear separation between one-time bootstrap and repeatable updates.

## Constraints
- Stubs live in a `defaults/` folder in the repo and are copied into place once.
- Stubs must reference configs in `~/.local/share/hyprdk/configs/...`.
- Update flow should only update the repo and run system updates; it should not touch stubs or system configs.

## Proposed Structure
- Repo root: `~/.local/share/hyprdk`
- Canonical configs: `~/.local/share/hyprdk/configs/`
- Stub templates: `~/.local/share/hyprdk/defaults/`
- Optional env: `HYPRDK_ROOT` (default to `XDG_DATA_HOME/hyprdk`)

## Implementation Phases

### 1) Capability Audit (includes vs wrappers)
Identify which apps can include/source external configs and which need wrappers.
- Hyprland: supports `source =` include (good for stubs).
- Zsh: supports sourcing (`~/.zshrc` stub can point to repo modules).
- Waybar: supports `include` in JSONC, but CSS may need absolute imports.
- Ghostty, matugen, btop, walker, etc.: verify include/path support or plan wrappers.

Deliverable: a table listing each app, stub method (include/path/wrapper), and target file paths.

### 2) Dynamic Output Strategy
Decide where generators write (matugen, hyprdynamicmonitors).
- Option A: outputs stay in `~/.config` and are referenced by stubs.
- Option B: outputs go into the repo (accepting a dirty repo).

Deliverable: a clear rule documented in README.

### 3) Stub Layout Design
Create minimal stubs under `defaults/`.
Examples (illustrative):
- `defaults/.config/hypr/hyprland.conf` -> `source = ~/.local/share/hyprdk/configs/.config/hypr/hyprland.conf`
- `defaults/.config/waybar/config.jsonc` -> include repo modules
- `defaults/.zshrc` -> source repo zsh modules

Deliverable: `defaults/` tree with stub files only.

### 4) Install Step Changes
Update the config install step to:
- Copy stubs from `defaults/` only when the target file does not exist.
- Never overwrite user stubs.
- Log when a stub already exists.

Deliverable: idempotent stub installer.

### 5) Bootstrap Behavior
Update `bootstrap.sh` to be one-time by default.
- If repo already exists, exit with instructions to run update.
- Allow a force flag for testing.

Deliverable: guarded bootstrap with a test override.

### 6) Update Flow
Add `hdk-update` (or `update.sh`) that:
- Pulls the repo in `~/.local/share/hyprdk`.
- Runs system update (pacman/paru) only.
- Does not touch `~/.config` stubs.

Deliverable: repeatable update script.

### 7) Documentation
Update `README.md` and `AGENTS.md`:
- New repo path and env variable.
- Bootstrap once vs update flow.
- Stub ownership and regeneration instructions.

Deliverable: clear docs aligned with the new workflow.

## Migration Checklist (manual)
- Move repo to `~/.local/share/hyprdk`.
- Remove old symlinks in `~/.config`.
- Copy stubs from `defaults/` into `~/.config`.
- Run update script and verify apps load repo configs.

## Open Questions
- Which apps require wrappers because they cannot include external configs?
- Where should matugen and hyprdynamicmonitors write outputs?
- Should update run pacman only or both pacman and paru?
