# lib/gum.sh — silent bootstrap of charm's gum
# only emits output if it actually has to install something (or fails).

ensure_gum() {
    if command -v gum >/dev/null 2>&1; then
        return 0
    fi

    log_info "installing gum (one-time TUI dependency)"

    if ! command -v curl >/dev/null 2>&1; then
        sudo apt-get install -y curl >/dev/null 2>&1 \
            || { log_error "could not install curl"; return 1; }
    fi

    local keyring="/etc/apt/keyrings/charm.gpg"
    sudo install -d -m 0755 /etc/apt/keyrings

    if [[ ! -s "$keyring" ]]; then
        curl -fsSL https://repo.charm.sh/apt/gpg.key \
            | sudo gpg --dearmor -o "$keyring" 2>/dev/null \
            || { log_error "failed to fetch charm GPG key"; return 1; }
    fi

    echo "deb [signed-by=${keyring}] https://repo.charm.sh/apt/ * *" \
        | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null

    sudo apt-get update -qq >/dev/null 2>&1 \
        || { log_error "apt update failed after adding charm repo"; return 1; }

    sudo apt-get install -y gum >/dev/null 2>&1 \
        || { log_error "apt install gum failed"; return 1; }

    log_success "gum ready"
}

# narrow style helpers so the TUI files don't repeat colour codes everywhere
gum_header() {
    gum style \
        --foreground 39 --bold --border double --border-foreground 39 \
        --padding "1 4" --margin "1 0" --align center \
        "$@"
}

gum_box() {
    gum style \
        --foreground 255 --border rounded --border-foreground 39 \
        --padding "1 2" --margin "0 0" \
        "$@"
}

gum_warn_box() {
    gum style \
        --foreground 255 --border rounded --border-foreground 214 \
        --padding "1 2" --margin "0 0" \
        "$@"
}

gum_muted() { gum style --foreground 240 "$@"; }
gum_ok()    { gum style --foreground 82  "$@"; }
gum_warn()  { gum style --foreground 214 "$@"; }
gum_err()   { gum style --foreground 196 "$@"; }
