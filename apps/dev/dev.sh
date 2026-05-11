# apps/dev/dev.sh — development tools

DEV_IDS=(vscode virtualbox)

APP_vscode_NAME="VS Code"
APP_vscode_DESC="Microsoft's editor (official packages.microsoft.com repo)."
APP_vscode_PROFILES=("dev")
APP_vscode_DEFAULT_IN=("dev")
install_vscode() {
    install_repo "VS Code" \
        "https://packages.microsoft.com/keys/microsoft.asc" \
        "/etc/apt/keyrings/packages.microsoft.gpg" \
        "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        "/etc/apt/sources.list.d/vscode.list" \
        "code"
}

APP_virtualbox_NAME="VirtualBox"
APP_virtualbox_DESC="Oracle VirtualBox + DKMS host modules."
APP_virtualbox_PROFILES=("dev")
APP_virtualbox_DEFAULT_IN=()
install_virtualbox() {
    install_apt "VirtualBox" virtualbox virtualbox-dkms virtualbox-guest-additions-iso
}
