#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${1:-"$(cd "$(dirname "$0")/.." && pwd)"}"

# ── homebrew ──────────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
  printf '  installing Homebrew…\n'
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
printf '  \033[1;32m✓\033[0m homebrew ready\n'

brew bundle --file="$DOTFILES_DIR/Brewfile"
printf '  \033[1;32m✓\033[0m packages installed\n'

# ── zap (zsh plugin manager) ──────────────────────────────────────────────────

if [[ ! -d "$HOME/.local/share/zap" ]]; then
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) \
    --branch release-v1 --keep-zshrc
  printf '  \033[1;32m✓\033[0m zap installed\n'
else
  printf '  \033[2mzap already present\033[0m\n'
fi
