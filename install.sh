#!/usr/bin/env bash
# mint-postinstall — Linux Mint 21.x (Cinnamon) one-shot setup
#
# Usage:
#   bash install.sh              run everything
#   bash install.sh --dry-run    print what would happen, change nothing
#
# Run as your normal user. sudo will be prompted once and kept alive.

set -euo pipefail

# ── pinned versions (bump as new releases ship) ───────────────────
PROTON_BRIDGE_VERSION="3.13.0-1"   # https://proton.me/mail/bridge
STACER_VERSION="1.1.0"             # https://github.com/oguzhaninan/Stacer/releases

# ── flags ─────────────────────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      sed -n '2,9p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

# ── guards ────────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  echo "run as your user, not root — sudo will be requested when needed" >&2
  exit 1
fi
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  [[ "${ID:-}" == "linuxmint" ]] || \
    echo "warning: detected '${ID:-unknown}', this script targets Linux Mint" >&2
fi

# ── output helpers ────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_DIM=$'\e[2m'; C_CYAN=$'\e[1;36m'; C_YELLOW=$'\e[1;33m'
  C_GREEN=$'\e[1;32m'; C_RED=$'\e[1;31m'; C_RESET=$'\e[0m'
else
  C_DIM= C_CYAN= C_YELLOW= C_GREEN= C_RED= C_RESET=
fi
section() { printf '\n%s━━━ %s ━━━%s\n' "$C_CYAN"   "$1" "$C_RESET"; }
note()    { printf '  %s· %s%s\n'        "$C_DIM"   "$1" "$C_RESET"; }
warn()    { printf '  %s! %s%s\n'        "$C_YELLOW" "$1" "$C_RESET" >&2; }
ok()      { printf '  %s✓ %s%s\n'        "$C_GREEN"  "$1" "$C_RESET"; }

do_step() {
  local label="$1" fn="$2"
  section "$label"
  if $DRY_RUN; then
    note "[dry-run] would run: $fn"
  else
    "$fn"
  fi
}

# ── reusable installers ───────────────────────────────────────────
add_repo() {
  # add_repo NAME KEY_URL REPO_LINE
  local name="$1" key_url="$2" repo_line="$3"
  curl -fsSL "$key_url" \
    | gpg --dearmor \
    | sudo tee "/usr/share/keyrings/${name}.gpg" >/dev/null
  echo "$repo_line" | sudo tee "/etc/apt/sources.list.d/${name}.list" >/dev/null
}

install_deb() {
  # install_deb URL [DESTNAME]
  local url="$1" deb="/tmp/${2:-$(basename "$1")}"
  curl -fsSL "$url" -o "$deb" || return 1
  sudo apt install -y "$deb"   || return 1
  rm -f "$deb"
}

apt_install() { sudo apt install -y "$@"; }

# ── steps ─────────────────────────────────────────────────────────
step_update() {
  sudo apt update
  sudo apt -y full-upgrade
  sudo apt -y autoremove
}

step_drivers() {
  apt_install ubuntu-drivers-common
  sudo ubuntu-drivers autoinstall \
    || warn "ubuntu-drivers autoinstall failed — open mintdrivers GUI to verify"
}

step_codecs() {
  apt_install \
    mint-meta-codecs \
    ffmpeg \
    libavcodec-extra
}

step_flatpak() {
  apt_install flatpak
  flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
}

step_signal() {
  curl -fsSL https://updates.signal.org/desktop/apt/keys.asc \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg >/dev/null
  sudo tee /etc/apt/sources.list.d/signal-desktop.sources >/dev/null <<'EOF'
Types: deb
URIs: https://updates.signal.org/desktop/apt
Suites: xenial
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/signal-desktop-keyring.gpg
EOF
  sudo apt update
  apt_install signal-desktop
}

step_vivaldi() {
  add_repo vivaldi-browser \
    https://repo.vivaldi.com/archive/linux_signing_key.pub \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi-browser.gpg] https://repo.vivaldi.com/archive/deb/ stable main"
  sudo apt update
  apt_install vivaldi-stable
}

step_vscode() {
  add_repo packages.microsoft \
    https://packages.microsoft.com/keys/microsoft.asc \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
  sudo apt update
  apt_install code
}

step_proton() {
  install_deb \
    https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb \
    protonvpn-release.deb
  sudo apt update
  apt_install proton-vpn-gnome-desktop

  install_deb \
    "https://proton.me/download/bridge/protonmail-bridge_${PROTON_BRIDGE_VERSION}_amd64.deb" \
    protonmail-bridge.deb \
    || warn "Bridge install failed — bump PROTON_BRIDGE_VERSION at top of script"
}

step_steam() {
  sudo dpkg --add-architecture i386
  sudo apt update
  apt_install steam-installer
}

step_apps() {
  apt_install \
    vlc \
    kdenlive \
    simplescreenrecorder \
    flameshot \
    kleopatra \
    clamtk \
    solaar
  install_deb \
    "https://github.com/oguzhaninan/Stacer/releases/download/v${STACER_VERSION}/stacer_${STACER_VERSION}_amd64.deb" \
    stacer.deb \
    || warn "Stacer install failed — repo is unmaintained; skip if needed"
}

step_themes() {
  apt_install \
    yaru-theme-gtk \
    yaru-theme-icon \
    yaru-theme-cursor \
    mint-themes \
    mint-y-icons

  gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'
  gsettings set org.cinnamon.desktop.interface gtk-theme    'Mint-L-Dark'
  gsettings set org.cinnamon.desktop.interface icon-theme   'Mint-Y-Yaru'
  # window-manager theme schema differs by Cinnamon version; try both
  gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-L-Dark' 2>/dev/null \
    || gsettings set org.cinnamon.wm.preferences  theme 'Mint-L-Dark' 2>/dev/null \
    || true
  gsettings set org.cinnamon.theme name 'Mint-L-Dark'
}

step_autoupdates() {
  apt_install mintupdate
  if command -v mintupdate-automation >/dev/null; then
    sudo mintupdate-automation upgrade    enable
    sudo mintupdate-automation autoremove enable
  else
    warn "mintupdate-automation missing — enable in Update Manager → Edit → Preferences"
  fi
}

step_timeshift() {
  apt_install timeshift
  sudo install -d /etc/timeshift
  sudo tee /etc/timeshift/timeshift.json >/dev/null <<'EOF'
{
  "backup_device_uuid" : "",
  "do_first_run_after_boot" : "false",
  "btrfs_mode" : "false",
  "stop_cron_emails" : "true",
  "schedule_monthly" : "false",
  "schedule_weekly"  : "true",
  "schedule_daily"   : "true",
  "schedule_hourly"  : "false",
  "schedule_boot"    : "false",
  "count_monthly" : "2",
  "count_weekly"  : "2",
  "count_daily"   : "2",
  "count_hourly"  : "0",
  "count_boot"    : "0",
  "exclude" : [],
  "exclude-apps" : []
}
EOF
  warn "open Timeshift to pick a backup destination — snapshots won't run until it's set"
}

step_cleanup() {
  sudo apt -y autoremove
  sudo apt clean
  rm -f /tmp/*.deb
}

# ── main ──────────────────────────────────────────────────────────
$DRY_RUN && printf '\n%s*** DRY-RUN — no changes will be made ***%s\n' \
  "$C_YELLOW" "$C_RESET"

# helpers depend on curl
command -v curl >/dev/null || { $DRY_RUN || sudo apt install -y curl; }

# cache sudo, keep it warm during long apt runs
if ! $DRY_RUN; then
  sudo -v
  ( while true; do sudo -nv 2>/dev/null; sleep 60; done ) &
  SUDO_KEEPALIVE=$!
  trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT
fi

export DEBIAN_FRONTEND=noninteractive

do_step "system update"        step_update
do_step "drivers"              step_drivers
do_step "multimedia codecs"    step_codecs
do_step "flatpak + flathub"    step_flatpak
do_step "signal desktop"       step_signal
do_step "vivaldi"              step_vivaldi
do_step "vs code"              step_vscode
do_step "proton vpn + bridge"  step_proton
do_step "steam"                step_steam
do_step "apps (vlc, kdenlive, ssr, flameshot, kleopatra, clamtk, solaar, stacer)"  step_apps
do_step "themes (Yaru cursor, Mint-L-Dark, Mint-Y-Yaru)"  step_themes
do_step "auto updates"         step_autoupdates
do_step "timeshift"            step_timeshift
do_step "cleanup"              step_cleanup

# ── done ──────────────────────────────────────────────────────────
printf '\n%s━━━ done ━━━%s\n\n' "$C_GREEN" "$C_RESET"
cat <<'EOF'
  manual steps after reboot:
  · proton mail bridge — launch and sign in
  · proton vpn         — launch and sign in
  · signal             — scan QR on phone to link
  · clamtk             — first-run virus DB update
  · timeshift          — set backup destination, take first snapshot
  · mintdrivers GUI    — verify recommended drivers applied

EOF

if ! $DRY_RUN; then
  read -rp "  reboot now? [y/N] " yn
  [[ "$yn" =~ ^[Yy]$ ]] && sudo reboot
fi
