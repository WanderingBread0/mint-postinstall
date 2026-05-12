#!/usr/bin/env bash
# mint-postinstall — interactive TUI post-install setup for Linux Mint 22.x Cinnamon
#
# Usage:
#   ./install.sh            run normally
#   ./install.sh --dry-run  walk full flow, install nothing
#   ./install.sh --help     show this header
#
# Run as your normal user — sudo will be requested when needed.

set -euo pipefail

# ── locate ourselves ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── flags ────────────────────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run)     DRY_RUN=true ;;
        -h|--help)     sed -n '2,9p' "$0" | sed 's/^# \?//'; exit 0 ;;
        *) echo "unknown arg: $arg" >&2; exit 2 ;;
    esac
done
export DRY_RUN

# ── guards ───────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    echo "run as your user, not root — sudo is invoked where needed" >&2
    exit 1
fi

# ── source libs (order matters: log -> gum -> install -> detect) ─
# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
# shellcheck source=lib/gum.sh
source "$SCRIPT_DIR/lib/gum.sh"
# shellcheck source=lib/install.sh
source "$SCRIPT_DIR/lib/install.sh"
# shellcheck source=lib/detect.sh
source "$SCRIPT_DIR/lib/detect.sh"

# ── bootstrap gum (silent unless it has to install) ──────────────
ensure_gum || { log_error "gum is required"; exit 1; }

# ── source app catalogs ──────────────────────────────────────────
for f in "$SCRIPT_DIR"/apps/*/*.sh; do
    # shellcheck source=/dev/null
    source "$f"
done

# Flatten every category's *_IDS array into a single canonical list. Used by
# the extras screen and the mode picker. Lives here (not in a tui file) so
# tui sourcing order doesn't matter.
ALL_IDS=(
    "${BROWSERS_IDS[@]}"
    "${PROTON_IDS[@]}"
    "${EMAIL_IDS[@]}"
    "${MESSENGERS_IDS[@]}"
    "${NOTES_IDS[@]}"
    "${GAMING_IDS[@]}"
    "${TERMINAL_IDS[@]}"
    "${UTILITIES_IDS[@]}"
    "${DEV_IDS[@]}"
    "${MEDIA_IDS[@]}"
)

# ── source TUI screens ───────────────────────────────────────────
for f in welcome profiles mode categories extras summary execute done; do
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/tui/$f.sh"
done

# ── keep sudo warm for long apt runs ─────────────────────────────
if ! $DRY_RUN; then
    sudo -v || { log_error "could not acquire sudo"; exit 1; }
    ( while true; do sudo -nv 2>/dev/null || exit; sleep 60; done ) &
    SUDO_KEEPALIVE=$!
    # shellcheck disable=SC2064
    trap "kill $SUDO_KEEPALIVE 2>/dev/null || true" EXIT
fi
export DEBIAN_FRONTEND=noninteractive

# ── pre-flight: flatpak + flathub, snap removal, system update ───
ensure_flathub || true

# ── run the flow ─────────────────────────────────────────────────
screen_welcome
screen_profiles
screen_mode

case "$INSTALL_MODE" in
    defaults)
        seed_from_defaults
        ;;
    customize)
        screen_categories
        screen_extras
        ;;
    full)
        seed_from_defaults
        screen_extras
        ;;
esac

screen_summary
screen_execute

# ── post-flight prompts ──────────────────────────────────────────
prompt_snap_removal
prompt_firmware_update
if profile_active dev; then
    prompt_git_config
    prompt_ssh_keygen
elif profile_active privacy; then
    prompt_ssh_keygen
fi
prompt_rog_tools

screen_done
