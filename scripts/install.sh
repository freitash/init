#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${1:-"$(cd "$(dirname "$0")" && pwd)"}"
SRC="$DOTFILES_DIR/dotfiles"

links=(
  "$SRC/zsh/.zshenv:$HOME/.zshenv"
  "$SRC/zsh/.zshrc:$HOME/.zshrc"
  "$SRC/git/.gitconfig:$HOME/.gitconfig"
  "$SRC/starship/.config/starship.toml:$HOME/.config/starship.toml"
  "$SRC/ghostty/config:$HOME/.config/ghostty/config"
  "$SRC/vscode/settings.json:$HOME/Library/Application Support/Code/User/settings.json"
  "$SRC/vscode/keybindings.json:$HOME/Library/Application Support/Code/User/keybindings.json"
)

for link in "${links[@]}"; do
  src="${link%%:*}"
  dst="${link##*:}"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  printf '  linked: %s\n' "$dst"
done

touch "$HOME/.hushlogin"  # suppress "Last login" message
