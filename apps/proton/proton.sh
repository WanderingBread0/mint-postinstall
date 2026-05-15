# apps/proton/proton.sh — Proton suite
# Note: Proton Drive has no official Linux client as of writing — excluded.

PROTON_IDS=(protonvpn protonmail protonbridge protonpass)

PROTON_BRIDGE_VERSION="${PROTON_BRIDGE_VERSION:-3.13.0-1}"

APP_protonvpn_NAME="ProtonVPN"
APP_protonvpn_DESC="Proton's official Linux VPN GUI."
APP_protonvpn_PROFILES=("privacy")
APP_protonvpn_DEFAULT_IN=("privacy")
install_protonvpn() {
    # Two-step install: the release .deb just drops repo + key files;
    # apt's cache doesn't know about the new proton repo yet, so we have
    # to apt-update before pulling the actual package.
    install_deb_url "ProtonVPN release package" \
        "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb" \
        || return 1
    if ! $DRY_RUN; then
        _spin "apt update for ProtonVPN" "sudo apt-get update -qq" \
            || { _record_fail "ProtonVPN"; return 1; }
    fi
    install_apt "ProtonVPN" proton-vpn-gnome-desktop
}

APP_protonmail_NAME="Proton Mail Desktop"
APP_protonmail_DESC="Native Proton Mail desktop app for Linux."
APP_protonmail_PROFILES=("privacy")
APP_protonmail_DEFAULT_IN=("privacy")
install_protonmail() {
    # Proton ships this as a direct .deb whose URL contains the current
    # version — pinning it here would 404 within weeks. Manual install
    # points the user at the canonical download page.
    manual_install "Proton Mail Desktop" \
        "https://proton.me/mail/download" \
        "Proton Mail Desktop is distributed as a versioned .deb from proton.me.
After download:
  sudo apt install ./ProtonMail-desktop-*.deb"
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
