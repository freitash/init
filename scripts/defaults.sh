#!/usr/bin/env bash
set -euo pipefail

# ── software update ───────────────────────────────────────────────────────────
# macOS 15.4+ may re-enable some of these after a feature update.
# Check System Settings > General > Software Update after any OS upgrade.

sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled            -bool false  # disable periodic background update checks
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload               -bool false  # don't silently download updates in the background
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false  # don't auto-install macOS updates
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall           -bool true

# ── keyboard ──────────────────────────────────────────────────────────────────

defaults write NSGlobalDomain KeyRepeat                           -int 2     # key repeat rate — lower is faster (default: 6)
defaults write NSGlobalDomain InitialKeyRepeat                    -int 15    # delay before key repeat kicks in — lower is shorter (default: 25)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false  # disable auto-correct
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled    -bool false  # disable auto-capitalisation at start of sentences
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled  -bool false  # disable smart dashes (-- stays --, not —)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false  # disable smart quotes (" stays ", not "")
defaults write NSGlobalDomain ApplePressAndHoldEnabled            -bool false  # disable press-and-hold accent menu; enables key repeat instead

# ── finder ────────────────────────────────────────────────────────────────────

defaults write com.apple.finder          NewWindowTarget          -string "PfDe"      # new Finder windows open in Desktop
defaults write com.apple.finder          NewWindowTargetPath      -string "file://${HOME}/Desktop/" # path for new Finder windows
defaults write com.apple.finder          AppleShowAllFiles        -bool true          # show hidden files (dotfiles etc.)
defaults write NSGlobalDomain            AppleShowAllExtensions   -bool true          # always show file extensions
defaults write com.apple.finder          _FXShowPosixPathInTitle  -bool true          # show full path in Finder title bar
defaults write com.apple.finder          FXPreferredViewStyle     -string "Nlsv"      # default to list view (icnv=icons, clmv=columns, Flwv=gallery)
defaults write com.apple.finder          FXDefaultSearchScope     -string "SCcf"      # search current folder by default, not the whole Mac
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true          # don't create .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores     -bool true          # don't create .DS_Store files on USB drives
defaults write com.apple.LaunchServices  LSQuarantine             -bool false         # disable "downloaded from the internet" warning dialog

# ── dock ──────────────────────────────────────────────────────────────────────

defaults write com.apple.dock autohide               -bool true    # auto-hide the dock when not in use
defaults write com.apple.dock autohide-delay         -float 0      # no delay before the dock appears on hover
defaults write com.apple.dock autohide-time-modifier -float 0.3    # dock slide animation duration in seconds (0 = instant)
defaults write com.apple.dock show-recents           -bool false   # hide the "Recent Applications" section in the dock
defaults write com.apple.dock mru-spaces             -bool false   # don't reorder Spaces based on most recent use
defaults write com.apple.dock "tilesize" -int "46"                 # dock icon size

printf '  Clear all pinned dock apps? [y/N]: '
read -r _clear_dock
case "$_clear_dock" in
  [yY]*) defaults write com.apple.dock persistent-apps -array ;;   # empty dock — no pinned apps
esac

# ── screenshots ───────────────────────────────────────────────────────────────

mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location       -string "$HOME/Desktop/Screenshots"  # save screenshots here instead of Desktop root
defaults write com.apple.screencapture type           -string "png"                        # screenshot format (png, jpg, pdf, tiff)
defaults write com.apple.screencapture disable-shadow -bool true                           # no drop shadow around windows in screenshots

# ── appearance ───────────────────────────────────────────────────────────────

defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true  # auto-switch dark/light mode based on sunrise/sunset
defaults write com.apple.WindowManager StandardHideWidgets              -int 1      # hide widgets on the desktop (normal mode)
defaults write com.apple.WindowManager StageManagerHideWidgets          -int 1      # hide widgets on the desktop (stage manager mode)

# ── privacy ───────────────────────────────────────────────────────────────────

defaults write com.apple.AdLib          allowApplePersonalizedAdvertising -bool false  # disable Apple personalised ads
defaults write com.apple.CrashReporter  DialogType                        -string "none"  # suppress crash report dialogs; stops prompting to send data to Apple
defaults write com.apple.assistant.support 'Assistant Enabled'            -bool false  # disable Siri
defaults write com.apple.gamed          Disabled                          -bool true   # disable Game Center

# ── misc ──────────────────────────────────────────────────────────────────────

defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true  # expand the Save dialog by default instead of the compact view
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint    -bool true  # expand the Print dialog by default instead of the compact view

# ── apply ─────────────────────────────────────────────────────────────────────

killall Finder 2>/dev/null || true
killall Dock   2>/dev/null || true
