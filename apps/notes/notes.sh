# apps/notes/notes.sh — notes & knowledge tools

NOTES_IDS=(standardnotes obsidian)

APP_standardnotes_NAME="Standard Notes"
APP_standardnotes_DESC="End-to-end encrypted notes. Sync requires account."
APP_standardnotes_PROFILES=("privacy")
APP_standardnotes_DEFAULT_IN=("privacy")
install_standardnotes() {
    ensure_flathub
    install_flatpak "Standard Notes" "org.standardnotes.standardnotes"
}

APP_obsidian_NAME="Obsidian"
APP_obsidian_DESC="Local-first Markdown notes / knowledge base."
APP_obsidian_PROFILES=("dev")
APP_obsidian_DEFAULT_IN=("dev")
install_obsidian() {
    ensure_flathub
    install_flatpak "Obsidian" "md.obsidian.Obsidian"
}
