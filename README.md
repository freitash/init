# init

Opinionated macOS setup for developers on Apple Silicon. Clone and run — fresh machine ready.

```bash
git clone https://github.com/freitash/init <your-folder> && bash <your-folder>/bootstrap.sh
```

---

## What's configured

**Shell** — zsh + [Zap](https://github.com/zap-zsh/zap), [starship](https://starship.rs) prompt, [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [zoxide](https://github.com/ajeetdsouza/zoxide)

**Git** — delta diffs, SSH commit signing, trunk-friendly defaults, automatic per-folder identity switching via `includeIf`

**Terminal** — [Ghostty](https://ghostty.org) with Flexoki theme + JetBrainsMono Nerd Font

**Editor** — VS Code with Flexoki theme, IntelliJ keybindings, sensible search/UI defaults

**Docker** — Colima (vz + virtiofs), Docker CLI + Compose plugin

**Apps** — Firefox, Chrome, Spotify, IINA, Slack, Bruno, Rectangle, Studio 3T, WebStorm

**macOS** — keyboard, Finder, Dock, screenshots, privacy tweaks, auto dark/light mode (sunrise/sunset), Touch ID for sudo ([mole](https://github.com/tw93/Mole))

---

## Structure

```
init/
├── bootstrap.sh      # entry point
├── Brewfile          # packages and apps
├── scripts/
│   ├── packages.sh   # homebrew + zap
│   ├── install.sh    # symlinks dotfiles/ into $HOME
│   ├── defaults.sh   # macOS system defaults
│   ├── docker.sh     # colima + docker compose config
│   ├── vscode.sh     # VS Code extensions
│   └── git.sh        # git identity setup (optional)
└── dotfiles/         # config files (symlinked into $HOME)
    ├── zsh/
    ├── git/
    ├── ghostty/
    ├── starship/
    └── vscode/
```

---

## Git identities

Bootstrap prompts to set up git identities (can be skipped). Each identity gets:

- A dedicated SSH key (`~/.ssh/id_ed25519_<slug>`)
- A `~/.gitconfig-<slug>` with name, email, and signing key
- An `includeIf gitdir:` block for automatic identity switching

Default folder convention: `~/workspace/<slug>` (e.g. `~/workspace/company`, `~/workspace/personal`). Later `includeIf` entries override earlier ones, so a personal folder nested inside the workspace root works correctly.

Re-running detects existing identities and offers to nuke and start fresh, or skip and add new ones.

---

## After setup

- Restart terminal
- WebStorm: Settings → Appearance → **Sync with OS** for dark/light

---

Re-running is safe — symlinks are overwritten, packages are updated, prompts guard destructive actions (dock clear, git identity reset).
