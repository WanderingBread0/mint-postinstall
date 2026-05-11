# apps/messengers/messengers.sh — chat / messaging clients
# Each carries a privacy bar (rough, opinionated — not a formal audit).

MESSENGERS_IDS=(signal session telegram element discord)

APP_signal_NAME="Signal"
APP_signal_DESC="Gold-standard E2E messenger. Requires phone number."
APP_signal_SCORE="▓▓▓▓▓▓▓▓▓░"
APP_signal_PROFILES=("privacy" "general")
APP_signal_DEFAULT_IN=("privacy")
install_signal() {
    install_repo "Signal" \
        "https://updates.signal.org/desktop/apt/keys.asc" \
        "/etc/apt/keyrings/signal.gpg" \
        "deb [arch=amd64 signed-by=/etc/apt/keyrings/signal.gpg] https://updates.signal.org/desktop/apt xenial main" \
        "/etc/apt/sources.list.d/signal-xenial.list" \
        "signal-desktop"
}

APP_session_NAME="Session"
APP_session_DESC="Onion-routed messenger, no phone number, no central server."
APP_session_SCORE="▓▓▓▓▓▓▓▓▓▓"
APP_session_PROFILES=("privacy")
APP_session_DEFAULT_IN=()
install_session() {
    ensure_flathub
    install_flatpak "Session" "network.loki.Session"
}

APP_telegram_NAME="Telegram"
APP_telegram_DESC="Default chats NOT E2E. Wide adoption, weak privacy posture."
APP_telegram_SCORE="▓▓▓▓░░░░░░"
APP_telegram_PROFILES=("general")
APP_telegram_DEFAULT_IN=()
install_telegram() {
    ensure_flathub
    install_flatpak "Telegram" "org.telegram.desktop"
}

APP_element_NAME="Element"
APP_element_DESC="Matrix client. E2E by default. Federated."
APP_element_SCORE="▓▓▓▓▓▓▓▓░░"
APP_element_PROFILES=("privacy")
APP_element_DEFAULT_IN=()
install_element() {
    ensure_flathub
    install_flatpak "Element" "im.riot.Riot"
}

APP_discord_NAME="Discord"
APP_discord_DESC="Popular but no E2E and harvests a lot of data."
APP_discord_SCORE="▓▓░░░░░░░░"
APP_discord_PROFILES=("gaming")
APP_discord_DEFAULT_IN=("gaming")
install_discord() {
    ensure_flathub
    install_flatpak "Discord" "com.discordapp.Discord"
}
