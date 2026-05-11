#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${1:-"$(cd "$(dirname "$0")/.." && pwd)"}"

prompt() {
  printf '  %s [%s]: ' "$1" "$2"
  local _input
  read -r _input
  printf -v "$3" '%s' "${_input:-$2}"
}

# ── ssh + gitconfig setup ─────────────────────────────────────────────────────

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# ── detect existing identities ────────────────────────────────────────────────

if [[ -s "$HOME/.gitconfig.local" ]] || compgen -G "$HOME/.gitconfig-*" >/dev/null 2>&1; then
  printf '\n  \033[1;33m⚠\033[0m Existing git identity config detected.\n'
  printf '  Nuke will remove: ~/.gitconfig.local, ~/.gitconfig-*, ~/.ssh/id_ed25519_*, ~/.ssh/allowed_signers\n'
  printf '  Reset and start fresh? [y/N]: '
  read -r _nuke_git
  case "$_nuke_git" in
    [yY]*)
      rm -f "$HOME/.gitconfig.local"
      rm -f "$HOME"/.gitconfig-*
      rm -f "$HOME"/.ssh/id_ed25519_*
      : > "$HOME/.ssh/allowed_signers"
      rm -f "$HOME/.config/gh/dir-mapping"
      printf '  git identities cleared\n'
      ;;
  esac
fi

touch "$HOME/.ssh/allowed_signers"
touch "$HOME/.gitconfig.local"

# ── shared: configure one identity ───────────────────────────────────────────

create_identity() {
  local slug="$1"
  local default_folder="$2"
  local git_name git_email git_folder

  prompt "Full name"           ""              git_name
  prompt "Email"               ""              git_email
  prompt "Base folder"         "$default_folder" git_folder
  git_folder="${git_folder/#\~/$HOME}"
  mkdir -p "$git_folder"

  # ssh key
  local key_file="$HOME/.ssh/id_ed25519_${slug}"
  if [[ -f "$key_file" ]]; then
    printf '  key %s already exists — skipping keygen\n' "$key_file"
  else
    ssh-keygen -t ed25519 -C "$git_email" -f "$key_file" -N ""
    printf '  ssh key: %s\n' "$key_file"
  fi

  # ~/.ssh/allowed_signers
  local pubkey
  pubkey="$(cat "${key_file}.pub")"
  local key_data
  key_data="$(awk '{print $2}' "${key_file}.pub")"
  if ! grep -qF "$key_data" "$HOME/.ssh/allowed_signers" 2>/dev/null; then
    printf '%s %s\n' "$git_email" "$pubkey" >> "$HOME/.ssh/allowed_signers"
  fi

  # ~/.gitconfig-<slug>
  local gitconfig_identity="$HOME/.gitconfig-${slug}"
  if [[ -f "$gitconfig_identity" ]] && ! grep -q "PLACEHOLDER_" "$gitconfig_identity"; then
    printf '  ~/.gitconfig-%s already configured — skipping\n' "$slug"
  else
    sed \
      -e "s|PLACEHOLDER_NAME|${git_name}|g" \
      -e "s|PLACEHOLDER_EMAIL|${git_email}|g" \
      -e "s|PLACEHOLDER_KEY|${key_file}.pub|g" \
      -e "s|PLACEHOLDER_SSH_KEY|${key_file}|g" \
      "$DOTFILES_DIR/dotfiles/git/.gitconfig-template" > "$gitconfig_identity"
    printf '  created ~/.gitconfig-%s\n' "$slug"
  fi

  # ~/.gitconfig.local — includeIf block
  local abs_folder
  abs_folder="$(cd "$git_folder" && pwd)/"
  if ! grep -qF "gitconfig-${slug}" "$HOME/.gitconfig.local" 2>/dev/null; then
    cat >> "$HOME/.gitconfig.local" <<EOF

[includeIf "gitdir:${abs_folder}"]
  path = ${gitconfig_identity}
EOF
    printf '  includeIf → %s\n' "$abs_folder"
  else
    printf '  includeIf for %s already present\n' "$slug"
  fi

  # print public key
  echo ""
  printf '  ── Public key for "%s" ──────────────────────────────────────\n' "$slug"
  cat "${key_file}.pub"
  printf '  ─────────────────────────────────────────────────────────────\n\n'
  printf '  Add the key above to https://github.com/settings/keys\n'
  printf '  as both an "Authentication key" and a "Signing key".\n'
  printf '  Press Enter when done… '
  read -r _

  # gh CLI account mapping
  local gh_user
  prompt "GitHub username for this identity" "" gh_user
  if [[ -n "$gh_user" ]]; then
    mkdir -p "$HOME/.config/gh"
    local mapfile="$HOME/.config/gh/dir-mapping"
    if ! grep -qF "${abs_folder}" "$mapfile" 2>/dev/null; then
      printf '%s\t%s\n' "$abs_folder" "$gh_user" >> "$mapfile"
      printf '  gh mapping: %s → %s\n' "$abs_folder" "$gh_user"
    fi
  fi
}

# ── identities ────────────────────────────────────────────────────────────────

while true; do
  echo ""
  local_slug=""
  while true; do
    prompt "Identity slug (e.g. work, personal)" "" local_slug
    [[ -n "$local_slug" ]] && break
    printf '  slug cannot be empty.\n'
  done

  if grep -qF ".gitconfig-${local_slug}" "$HOME/.gitconfig.local" 2>/dev/null; then
    printf '  \033[2m%s identity already configured — skipping\033[0m\n' "$local_slug"
  else
    printf '\n  \033[1;34m── %s identity ──────────────────────────────\033[0m\n\n' "$local_slug"
    create_identity "$local_slug" "$HOME/workspace"
  fi

  printf '\n  Add another identity? [y/N]: '
  read -r _more
  [[ "$_more" =~ ^[yY] ]] || break
done

# ── summary ───────────────────────────────────────────────────────────────────

echo ""
printf '  \033[1;34mUsage:\033[0m\n'
printf '  Repos under each identity folder auto-use the correct name/email/key.\n'
printf '  Standard git@github.com: URLs work — the right SSH key is selected\n'
printf '  automatically via core.sshCommand based on the repo location.\n\n'
