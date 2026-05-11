# ── homebrew ──────────────────────────────────────────────────────────────────
# Must come first — sets PATH, HOMEBREW_PREFIX, and other brew env vars.

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── editor ────────────────────────────────────────────────────────────────────
# Set to 'code --wait' if VS Code is installed and preferred.

export EDITOR="vim"

# ── telemetry opt-outs ────────────────────────────────────────────────────────

export DO_NOT_TRACK=1                     # general standard
export NUXT_TELEMETRY_DISABLED=1          # Nuxt

# ── misc ─────────────────────────────────────────────────────────────────────

export NX_TUI=false