#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${HYPR_BOOTSTRAP_REPO:-https://github.com/Furyfree/hypr-bootstrap.git}"
TARGET_DIR="${HYPR_BOOTSTRAP_DIR:-$HOME/git/hypr-bootstrap}"
REF="${HYPR_BOOTSTRAP_REF:-}"

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || die "git is required"

mkdir -p "$(dirname "$TARGET_DIR")"

if [ -d "$TARGET_DIR/.git" ]; then
  log "Repo exists at $TARGET_DIR. Updating..."
  git -C "$TARGET_DIR" fetch --all --prune
  if [ -n "$REF" ]; then
    git -C "$TARGET_DIR" checkout "$REF"
  fi
  git -C "$TARGET_DIR" pull --ff-only
else
  if [ -e "$TARGET_DIR" ] && [ -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
    die "$TARGET_DIR exists and is not empty"
  fi
  log "Cloning $REPO_URL to $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
  if [ -n "$REF" ]; then
    git -C "$TARGET_DIR" checkout "$REF"
  fi
fi

log "Running install.sh"
exec bash "$TARGET_DIR/install.sh"
