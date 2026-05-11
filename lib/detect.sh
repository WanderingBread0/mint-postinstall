# lib/detect.sh — hardware / system detection + post-install prompts

is_asus_rog() {
    local vendor=""
    [[ -r /sys/class/dmi/id/sys_vendor ]] \
        && vendor="$(tr '[:upper:]' '[:lower:]' </sys/class/dmi/id/sys_vendor)"
    local product=""
    [[ -r /sys/class/dmi/id/product_name ]] \
        && product="$(tr '[:upper:]' '[:lower:]' </sys/class/dmi/id/product_name)"

    [[ "$vendor" == *asus* ]] || return 1
    [[ "$product" == *rog* || "$product" == *zephyrus* || "$product" == *tuf* ]]
}

snap_is_installed() {
    command -v snap >/dev/null 2>&1 || dpkg -l snapd >/dev/null 2>&1
}

prompt_snap_removal() {
    snap_is_installed || return 0
    log_step "snap detected"
    gum_warn_box \
        "Linux Mint ships with snap blocked by default, but it appears" \
        "snap or snapd is installed on this system." \
        "" \
        "Removing it restores Mint's default behaviour and frees disk." \
        "Some apps (e.g. installed by upstream Ubuntu tooling) may break."
    if gum confirm "Remove snap and pin it so apt won't reinstall it?"; then
        if $DRY_RUN; then
            log_skip "[dry-run] would remove snapd and pin via apt preferences"
            return 0
        fi
        _spin "removing snap packages" \
            "sudo snap list 2>/dev/null | awk 'NR>1{print \$1}' | xargs -r -n1 sudo snap remove --purge" \
            || true
        _spin "purging snapd" "sudo apt-get purge -y snapd" || true
        sudo tee /etc/apt/preferences.d/nosnap.pref >/dev/null <<'EOF'
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
        log_success "snap removed and pinned"
    else
        log_skip "leaving snap in place"
    fi
}

prompt_rog_tools() {
    is_asus_rog || return 0
    log_step "ASUS ROG hardware detected"
    gum_box \
        "$(gum style --foreground 39 --bold "ASUS ROG laptop detected")" \
        "" \
        "Companion tooling is available for fan profiles, GPU mode," \
        "and keyboard lighting control:" \
        "" \
        "  · rog-power-switch   — TDP / fan profile hotkeys" \
        "  · rog-control-panel  — GUI for asusctl / supergfxctl" \
        "" \
        "$(gum_muted "These are separate repos and will not be installed here.")"
    if gum confirm "Open the companion repos in your browser?"; then
        command -v xdg-open >/dev/null 2>&1 || return 0
        xdg-open "https://github.com/WanderingBread0/rog-power-switch"  >/dev/null 2>&1 &
        xdg-open "https://github.com/WanderingBread0/rog-control-panel" >/dev/null 2>&1 &
    fi
}

prompt_firmware_update() {
    command -v fwupdmgr >/dev/null 2>&1 || {
        log_info "installing fwupd for firmware updates"
        $DRY_RUN || sudo apt-get install -y fwupd >/dev/null 2>&1 || return 0
    }
    $DRY_RUN && { log_skip "[dry-run] would check fwupdmgr"; return 0; }

    log_step "firmware updates"
    if gum confirm "Check for firmware updates with fwupdmgr now?"; then
        sudo fwupdmgr refresh --force || true
        sudo fwupdmgr get-updates    || true
        if gum confirm "Apply any updates fwupd offered?"; then
            sudo fwupdmgr update -y || true
        fi
    fi
}

# returns 0 if at least one key already exists in ~/.ssh
ssh_key_exists() {
    [[ -f "$HOME/.ssh/id_ed25519" || -f "$HOME/.ssh/id_rsa" || -f "$HOME/.ssh/id_ecdsa" ]]
}

prompt_ssh_keygen() {
    if ssh_key_exists; then
        log_skip "ssh key already present in ~/.ssh — leaving alone"
        return 0
    fi
    gum confirm "Generate a new ed25519 SSH key now?" || { log_skip "no ssh key generated"; return 0; }
    local email
    email="$(gum input --placeholder "you@example.com" --prompt "email for key comment: ")"
    [[ -z "$email" ]] && { log_warn "no email entered, skipping"; return 0; }
    if $DRY_RUN; then
        log_skip "[dry-run] would: ssh-keygen -t ed25519 -C '$email'"
        return 0
    fi
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N "" \
        && log_success "ssh key written to ~/.ssh/id_ed25519"
}

prompt_git_config() {
    if [[ -n "$(git config --global user.name 2>/dev/null)" \
       && -n "$(git config --global user.email 2>/dev/null)" ]]; then
        log_skip "git already configured ($(git config --global user.name) <$(git config --global user.email)>)"
        return 0
    fi
    gum confirm "Configure global git user.name / user.email now?" || { log_skip "git not configured"; return 0; }
    local name email
    name="$(gum input  --placeholder "Jane Doe"        --prompt "git user.name:  ")"
    email="$(gum input --placeholder "jane@example.com" --prompt "git user.email: ")"
    if $DRY_RUN; then
        log_skip "[dry-run] would: git config --global user.name '$name'; user.email '$email'"
        return 0
    fi
    [[ -n "$name"  ]] && git config --global user.name  "$name"
    [[ -n "$email" ]] && git config --global user.email "$email"
    git config --global init.defaultBranch main
    log_success "git configured"
}
