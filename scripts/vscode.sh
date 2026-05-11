#!/usr/bin/env bash
set -euo pipefail

# ── vs code ───────────────────────────────────────────────────────────────────

vscode_extensions=(
  "raillyhugo.one-hunter"                # Flexoki Light / Flexoki Dark themes
  "k--kato.intellij-idea-keybindings"    # IntelliJ IDEA keybindings
)

if command -v code &>/dev/null; then
  for ext in "${vscode_extensions[@]}"; do
    code --install-extension "${ext%% *}" --force &>/dev/null
    printf '  installed: %s\n' "${ext%% *}"
  done
else
  printf '  skipping — "code" CLI not found\n'
fi
