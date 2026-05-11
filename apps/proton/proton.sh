# apps/proton/proton.sh — Proton suite
# Note: Proton Drive has no official Linux client as of writing — excluded.

PROTON_IDS=(protonvpn protonbridge protonpass)

PROTON_BRIDGE_VERSION="${PROTON_BRIDGE_VERSION:-3.13.0-1}"

APP_protonvpn_NAME="ProtonVPN"
APP_protonvpn_DESC="Proton's official Linux VPN GUI."
APP_protonvpn_PROFILES=("privacy")
APP_protonvpn_DEFAULT_IN=("privacy")
install_protonvpn() {
    install_deb_url "ProtonVPN release package" \
        "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb" \
        || return 1
    install_apt "ProtonVPN" proton-vpn-gnome-desktop
}

APP_protonbridge_NAME="Proton Mail Bridge"
APP_protonbridge_DESC="Bridges Proton Mail to IMAP/SMTP clients. Requires paid plan."
APP_protonbridge_PROFILES=("privacy")
APP_protonbridge_DEFAULT_IN=()
install_protonbridge() {
    install_deb_url "Proton Mail Bridge" \
        "https://proton.me/download/bridge/protonmail-bridge_${PROTON_BRIDGE_VERSION}_amd64.deb"
}

APP_protonpass_NAME="Proton Pass"
APP_protonpass_DESC="Proton's password manager (flatpak)."
APP_protonpass_PROFILES=("privacy")
APP_protonpass_DEFAULT_IN=()
install_protonpass() {
    ensure_flathub
    install_flatpak "Proton Pass" "me.proton.Pass"
}
