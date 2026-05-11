# apps/utilities/utilities.sh — general-purpose tools

UTILITIES_IDS=(flameshot stacer clamtk rustdesk vlc)

APP_flameshot_NAME="Flameshot"
APP_flameshot_DESC="Annotation-heavy screenshot tool."
APP_flameshot_PROFILES=("privacy" "gaming" "dev" "content" "general")
APP_flameshot_DEFAULT_IN=("privacy" "gaming" "dev" "content" "general")
install_flameshot() { install_apt "Flameshot" flameshot; }

APP_stacer_NAME="Stacer"
APP_stacer_DESC="System monitor and cleaner."
APP_stacer_PROFILES=("general")
APP_stacer_DEFAULT_IN=("general")
install_stacer() { install_apt "Stacer" stacer; }

APP_clamtk_NAME="ClamTK"
APP_clamtk_DESC="GUI for the ClamAV antivirus engine."
APP_clamtk_PROFILES=("privacy")
APP_clamtk_DEFAULT_IN=("privacy")
install_clamtk() { install_apt "ClamTK" clamtk; }

APP_rustdesk_NAME="RustDesk"
APP_rustdesk_DESC="Self-hostable remote-desktop tool, open source TeamViewer-alt."
APP_rustdesk_PROFILES=("dev")
APP_rustdesk_DEFAULT_IN=()
install_rustdesk() {
    # latest stable .deb — pinned URL to keep things deterministic
    install_deb_url "RustDesk" \
        "https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-1.4.2-x86_64.deb"
}

APP_vlc_NAME="VLC"
APP_vlc_DESC="Plays anything."
APP_vlc_PROFILES=("general")
APP_vlc_DEFAULT_IN=("general")
install_vlc() { install_apt "VLC" vlc; }
