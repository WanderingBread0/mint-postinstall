# apps/terminal/terminal.sh — terminal emulators, multiplexers, shells

TERMINAL_IDS=(tmux terminator tilix zsh neofetch)

APP_tmux_NAME="Tmux"
APP_tmux_DESC="Terminal multiplexer."
APP_tmux_PROFILES=("dev")
APP_tmux_DEFAULT_IN=("dev")
install_tmux() { install_apt "Tmux" tmux; }

APP_terminator_NAME="Terminator"
APP_terminator_DESC="Tabbed/split terminal emulator."
APP_terminator_PROFILES=("dev")
APP_terminator_DEFAULT_IN=()
install_terminator() { install_apt "Terminator" terminator; }

APP_tilix_NAME="Tilix"
APP_tilix_DESC="Tiling GTK terminal."
APP_tilix_PROFILES=("dev")
APP_tilix_DEFAULT_IN=()
install_tilix() { install_apt "Tilix" tilix; }

APP_zsh_NAME="Zsh + Oh My Zsh"
APP_zsh_DESC="zsh shell with the Oh My Zsh framework."
APP_zsh_PROFILES=("dev")
APP_zsh_DEFAULT_IN=("dev")
install_zsh() {
    install_apt "Zsh" zsh git curl || return 1
    if $DRY_RUN; then
        _record_dryrun "Oh My Zsh"
        return 0
    fi
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        _record_skip "Oh My Zsh"
        return 0
    fi
    if _spin "installing Oh My Zsh" \
        "RUNZSH=no CHSH=no sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    then
        _record_ok "Oh My Zsh"
    else
        _record_fail "Oh My Zsh"
    fi
}

APP_neofetch_NAME="Neofetch"
APP_neofetch_DESC="System info screenshot tool."
APP_neofetch_PROFILES=("dev" "general")
APP_neofetch_DEFAULT_IN=("dev" "general")
install_neofetch() { install_apt "Neofetch" neofetch; }
