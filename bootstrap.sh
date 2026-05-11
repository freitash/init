#!/usr/bin/env bash
set -euo pipefail

# ── helpers ───────────────────────────────────────────────────────────────────

step()  { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }
ok()    { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
abort() { printf '\n\033[1;31mError: %s\033[0m\n' "$1" >&2; exit 1; }

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── phase 1: xcode clt ───────────────────────────────────────────────────────

step "Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  xcode-select --install 2>/dev/null || true
  echo ""
  abort "Xcode CLT not installed. Re-run this script after the installation completes."
fi
ok "Xcode CLT"

# ── phase 2: packages ────────────────────────────────────────────────────────

step "Packages"
sudo -v
bash "$DOTFILES_DIR/scripts/packages.sh" "$DOTFILES_DIR"
eval "$(/opt/homebrew/bin/brew shellenv)"
ok "Packages"

# ── phase 3: symlinks ────────────────────────────────────────────────────────

step "Symlinks"
bash "$DOTFILES_DIR/scripts/install.sh" "$DOTFILES_DIR"
ok "Symlinks"

# ── phase 4: macos defaults ──────────────────────────────────────────────────

step "macOS defaults"
bash "$DOTFILES_DIR/scripts/defaults.sh"
ok "macOS defaults"

# ── phase 4b: touch id for sudo ──────────────────────────────────────────────

step "Touch ID for sudo"
mo touchid
ok "Touch ID"

# ── phase 5: vs code ─────────────────────────────────────────────────────────

step "VS Code extensions"
bash "$DOTFILES_DIR/scripts/vscode.sh"
ok "VS Code"

# ── phase 6: docker / colima ──────────────────────────────────────────────────

step "Docker & Colima"
bash "$DOTFILES_DIR/scripts/docker.sh"
ok "Docker & Colima"

# ── phase 7: ghostty ─────────────────────────────────────────────────────────

step "Ghostty"
bash "$DOTFILES_DIR/scripts/ghostty.sh"
ok "Ghostty"

# ── phase 8: git identities ──────────────────────────────────────────────────

step "Git identities"
printf '  Set up git identities? [y/N]: '
read -r _setup_git
case "$_setup_git" in
  [yY]*)
    bash "$DOTFILES_DIR/scripts/git.sh" "$DOTFILES_DIR"
    ok "Git identities"
    ;;
  *) printf '  skipped\n' ;;
esac

# ── done ─────────────────────────────────────────────────────────────────────

printf '\n\033[1;32m==> All done!\033[0m\n'
cat <<EOF

  Dotfiles: $DOTFILES_DIR

  Next steps:
    1. Restart terminal

EOF
