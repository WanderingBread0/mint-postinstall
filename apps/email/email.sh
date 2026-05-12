# apps/email/email.sh — email clients & webmail wrappers.
#
# Linux has no native Outlook client and no official Gmail desktop app.
# The realistic options:
#   · Thunderbird   real client, supports Gmail + Outlook over OAuth
#   · Evolution     GNOME PIM, does Exchange/Outlook via evolution-ews
#   · Geary         lightweight modern client
#   · Gmail Desktop community Electron wrapper for the Gmail web UI
#   · Outlook       no Linux client — manual_install opens outlook.live.com

EMAIL_IDS=(thunderbird evolution geary gmail outlook)

APP_thunderbird_NAME="Thunderbird"
APP_thunderbird_DESC="Mozilla's mail client. Handles Gmail and Outlook via OAuth."
APP_thunderbird_PROFILES=("general" "privacy" "dev")
APP_thunderbird_DEFAULT_IN=("general")
install_thunderbird() { install_apt "Thunderbird" thunderbird; }

APP_evolution_NAME="Evolution"
APP_evolution_DESC="GNOME mail/calendar/contacts. Exchange/Outlook via evolution-ews."
APP_evolution_PROFILES=("general")
APP_evolution_DEFAULT_IN=()
install_evolution() { install_apt "Evolution" evolution evolution-ews; }

APP_geary_NAME="Geary"
APP_geary_DESC="Lightweight modern email client (GNOME)."
APP_geary_PROFILES=("general")
APP_geary_DEFAULT_IN=()
install_geary() { install_apt "Geary" geary; }

APP_gmail_NAME="Gmail Desktop"
APP_gmail_DESC="Community Electron wrapper for Gmail web. No official Linux client exists."
APP_gmail_PROFILES=("general")
APP_gmail_DEFAULT_IN=()
install_gmail() {
    ensure_flathub
    install_flatpak "Gmail Desktop" "dev.timsueberkrueb.GmailDesktop"
}

APP_outlook_NAME="Outlook (web)"
APP_outlook_DESC="No native Linux client. Opens outlook.live.com; Thunderbird is the better path."
APP_outlook_PROFILES=("general")
APP_outlook_DEFAULT_IN=()
install_outlook() {
    manual_install "Outlook" \
        "https://outlook.live.com/" \
        "Microsoft does not ship a native Linux Outlook client.
Best options:
  · Thunderbird           — works with Outlook OAuth out of the box
  · Evolution + ews       — full Exchange protocol support
  · This 'install'        — just opens outlook.live.com in your browser"
}
