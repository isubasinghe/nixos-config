#!/usr/bin/env bash
set -euo pipefail

# Bundle personal data for the NixOS ISO
DEST="${1:-./data-bundle.tar.gz}"
HOME_DIR="/home/isubasinghe"
WORK_DIR=$(mktemp -d)

trap 'rm -rf "$WORK_DIR"' EXIT

echo "==> Collecting personal data..."

# Personal data directories
for dir in Documents Desktop Pictures work "Calibre Library" life bin; do
  if [ -d "$HOME_DIR/$dir" ]; then
    echo "  $dir"
    mkdir -p "$WORK_DIR/home/$dir"
    rsync -a "$HOME_DIR/$dir/" "$WORK_DIR/home/$dir/"
  fi
done

# Projects (source only, no build artifacts)
echo "  Projects (source only)"
rsync -a \
  --exclude='target' \
  --exclude='node_modules' \
  --exclude='.next' \
  --exclude='build' \
  --exclude='__pycache__' \
  --exclude='dist' \
  --exclude='.gradle' \
  --exclude='bin' \
  --exclude='obj' \
  --exclude='.cache' \
  --exclude='.build' \
  --exclude='result' \
  --exclude='_build' \
  --exclude='vendor' \
  --exclude='.git' \
  "$HOME_DIR/Projects/" "$WORK_DIR/home/Projects/"

# Dotfiles
echo "  Dotfiles"
for f in .bashrc .gitconfig .databrickscfg; do
  [ -f "$HOME_DIR/$f" ] && cp -a "$HOME_DIR/$f" "$WORK_DIR/home/"
done

# SSH & GPG keys
for d in .ssh .gnupg; do
  [ -d "$HOME_DIR/$d" ] && cp -a "$HOME_DIR/$d" "$WORK_DIR/home/"
done

# Auth & credentials
echo "  Auth tokens & credentials"
mkdir -p "$WORK_DIR/home/.kube"
[ -f "$HOME_DIR/.kube/config" ] && cp -a "$HOME_DIR/.kube/config" "$WORK_DIR/home/.kube/"

for d in .config/gh .config/1Password .beyond-identity ".config/Mullvad VPN" .azure .docker; do
  if [ -d "$HOME_DIR/$d" ]; then
    mkdir -p "$WORK_DIR/home/$d"
    rsync -a "$HOME_DIR/$d/" "$WORK_DIR/home/$d/"
  fi
done

# GNOME keyring
if [ -d "$HOME_DIR/.local/share/keyrings" ]; then
  mkdir -p "$WORK_DIR/home/.local/share/keyrings"
  cp -a "$HOME_DIR/.local/share/keyrings/"* "$WORK_DIR/home/.local/share/keyrings/"
fi

# Firefox - key files only (logins, cookies, bookmarks, extensions, sessions)
echo "  Firefox profile (key files only)"
FF_PROFILE="$HOME_DIR/.mozilla/firefox/th7b0s9a.default-release"
FF_DEST="$WORK_DIR/home/.mozilla/firefox/th7b0s9a.default-release"
mkdir -p "$FF_DEST"

# Profile metadata
cp -a "$HOME_DIR/.mozilla/firefox/profiles.ini" "$WORK_DIR/home/.mozilla/firefox/" 2>/dev/null || true
cp -a "$HOME_DIR/.mozilla/firefox/installs.ini" "$WORK_DIR/home/.mozilla/firefox/" 2>/dev/null || true

# Core profile files
for f in cookies.sqlite logins.json key4.db cert9.db places.sqlite favicons.sqlite \
         permissions.sqlite formhistory.sqlite handlers.json search.json.mozlz4 \
         prefs.js user.js xulstore.json; do
  [ -f "$FF_PROFILE/$f" ] && cp -a "$FF_PROFILE/$f" "$FF_DEST/"
done

# Extensions, bookmarks, session, sync
for d in extensions sessionstore-backups bookmarkbackups weave; do
  [ -d "$FF_PROFILE/$d" ] && cp -a "$FF_PROFILE/$d" "$FF_DEST/"
done

# Slack (without caches)
echo "  Slack (session data only)"
if [ -d "$HOME_DIR/.config/Slack" ]; then
  rsync -a \
    --exclude='Cache' \
    --exclude='Code Cache' \
    --exclude='Service Worker' \
    --exclude='GPUCache' \
    "$HOME_DIR/.config/Slack/" "$WORK_DIR/home/.config/Slack/"
fi

# Chrome (Default profile)
echo "  Chrome profile"
if [ -d "$HOME_DIR/.config/google-chrome/Default" ]; then
  mkdir -p "$WORK_DIR/home/.config/google-chrome"
  rsync -a \
    --exclude='Cache' \
    --exclude='Code Cache' \
    --exclude='Service Worker' \
    --exclude='GPUCache' \
    "$HOME_DIR/.config/google-chrome/Default/" "$WORK_DIR/home/.config/google-chrome/Default/"
  # Also grab top-level chrome config
  cp -a "$HOME_DIR/.config/google-chrome/Local State" "$WORK_DIR/home/.config/google-chrome/" 2>/dev/null || true
fi

# Config dirs worth keeping (small, user-configured)
echo "  App configs"
for d in .config/nvim .config/wezterm .config/obs-studio .config/calibre; do
  if [ -d "$HOME_DIR/$d" ]; then
    mkdir -p "$WORK_DIR/home/$d"
    rsync -a "$HOME_DIR/$d/" "$WORK_DIR/home/$d/"
  fi
done

echo "==> Creating tarball..."
tar czf "$DEST" -C "$WORK_DIR" home

SIZE=$(du -sh "$DEST" | cut -f1)
echo "==> Done! Bundle: $DEST ($SIZE)"
