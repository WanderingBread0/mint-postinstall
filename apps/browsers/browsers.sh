# apps/browsers/browsers.sh — web browsers

BROWSERS_IDS=(firefox vivaldi librewolf chrome operagx)

APP_firefox_NAME="Firefox"
APP_firefox_DESC="Mozilla Firefox (Mint .deb, not snap)."
APP_firefox_PROFILES=("privacy" "general")
APP_firefox_DEFAULT_IN=("privacy" "general")
install_firefox() { install_apt "Firefox" firefox; }

APP_vivaldi_NAME="Vivaldi"
APP_vivaldi_DESC="Chromium-based browser with strong customisation."
APP_vivaldi_PROFILES=("privacy" "general")
APP_vivaldi_DEFAULT_IN=("privacy")
install_vivaldi() {
    install_repo "Vivaldi" \
        "https://repo.vivaldi.com/archive/linux_signing_key.pub" \
        "/etc/apt/keyrings/vivaldi.gpg" \
        "deb [arch=amd64 signed-by=/etc/apt/keyrings/vivaldi.gpg] https://repo.vivaldi.com/archive/deb/ stable main" \
        "/etc/apt/sources.list.d/vivaldi.list" \
        "vivaldi-stable"
}

APP_librewolf_NAME="LibreWolf"
APP_librewolf_DESC="Hardened, telemetry-free Firefox fork."
APP_librewolf_PROFILES=("privacy")
APP_librewolf_DEFAULT_IN=()
install_librewolf() {
    ensure_flathub
    install_flatpak "LibreWolf" "io.gitlab.librewolf-community"
}

APP_chrome_NAME="Google Chrome"
APP_chrome_DESC="Google's Chrome. Not privacy-respecting."
APP_chrome_PROFILES=("general")
APP_chrome_DEFAULT_IN=()
install_chrome() {
    install_deb_url "Google Chrome" \
        "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
}

APP_operagx_NAME="Opera GX"
APP_operagx_DESC="Gamer-flavoured Opera build, Discord/Twitch integrations."
APP_operagx_PROFILES=("gaming")
APP_operagx_DEFAULT_IN=("gaming")
install_operagx() {
    install_repo "Opera GX" \
        "https://deb.opera.com/archive.key" \
        "/etc/apt/keyrings/opera.gpg" \
        "deb [arch=amd64 signed-by=/etc/apt/keyrings/opera.gpg] https://deb.opera.com/opera-gx/ stable non-free" \
        "/etc/apt/sources.list.d/opera-gx.list" \
        "opera-gx-stable"
}
