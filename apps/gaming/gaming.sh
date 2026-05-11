# apps/gaming/gaming.sh — gaming apps

GAMING_IDS=(steam lutris)

APP_steam_NAME="Steam"
APP_steam_DESC="Valve's game launcher. Enables multilib (i386)."
APP_steam_PROFILES=("gaming")
APP_steam_DEFAULT_IN=("gaming")
install_steam() {
    if $DRY_RUN; then
        _record_dryrun "Steam (enables i386 multilib)"
        return 0
    fi
    _spin "enabling i386 arch" "sudo dpkg --add-architecture i386 && sudo apt-get update -qq" \
        || { _record_fail "Steam"; return 1; }
    install_apt "Steam" steam-installer
}

APP_lutris_NAME="Lutris"
APP_lutris_DESC="Game launcher for non-Steam titles & emulation."
APP_lutris_PROFILES=("gaming")
APP_lutris_DEFAULT_IN=("gaming")
install_lutris() {
    ensure_flathub
    install_flatpak "Lutris" "net.lutris.Lutris"
}
