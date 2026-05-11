#!/usr/bin/env bash
set -euo pipefail

# ── colima default config ─────────────────────────────────────────────────────

if [[ ! -f "$HOME/.colima/default/colima.yaml" ]]; then
  colima start --cpu 4 --memory 8 --vm-type vz --mount-type virtiofs --save-config
  colima stop
  printf '  colima config created\n'
else
  printf '  colima config already exists — skipping\n'
fi

# ── docker cli config (compose plugin) ───────────────────────────────────────

mkdir -p "$HOME/.docker"

if [[ ! -f "$HOME/.docker/config.json" ]]; then
  cat > "$HOME/.docker/config.json" <<'EOF'
{
  "cliPluginsExtraDirs": [
      "/opt/homebrew/lib/docker/cli-plugins"
  ]
}
EOF
  printf '  docker config created\n'
else
  printf '  \033[1;33m⚠\033[0m ~/.docker/config.json already exists — verify it contains cliPluginsExtraDirs\n'
fi
