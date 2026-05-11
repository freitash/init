#!/usr/bin/env bash
set -euo pipefail

# ── ghostty working directory ─────────────────────────────────────────────────

printf '  Ghostty default working directory [%s]: ' "$HOME/workspace"
read -r _ghostty_dir
_ghostty_dir="${_ghostty_dir:-$HOME/workspace}"
_ghostty_dir="${_ghostty_dir/#\~/$HOME}"
mkdir -p "$HOME/.config/ghostty"
printf 'working-directory = %s\n' "$_ghostty_dir" > "$HOME/.config/ghostty/config.local"
printf '  ghostty working directory → %s\n' "$_ghostty_dir"
