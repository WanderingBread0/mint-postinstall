# tui/welcome.sh — opening splash + Mint version check

screen_welcome() {
    clear
    gum_header "mint-postinstall" "Linux Mint 22.x Cinnamon"

    local mint_id="" mint_ver=""
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        mint_id="${ID:-}"
        mint_ver="${VERSION_ID:-}"
    fi

    local status_line
    if [[ "$mint_id" == "linuxmint" && "$mint_ver" == 22* ]]; then
        status_line="$(gum_ok "✓ detected Linux Mint ${mint_ver}")"
    elif [[ "$mint_id" == "linuxmint" ]]; then
        status_line="$(gum_warn "! detected Linux Mint ${mint_ver} — script targets 22.x")"
    else
        status_line="$(gum_warn "! detected '${mint_id:-unknown}' — script is tuned for Mint 22.x")"
    fi

    gum_box \
        "Curated, profile-based post-install for fresh Mint installs." \
        "" \
        "  1. Pick one or more profiles" \
        "  2. Per-category app selection (defaults pre-checked)" \
        "  3. Browse the full catalog under Extras" \
        "  4. Review summary → confirm → walk away" \
        "" \
        "$status_line"

    if $DRY_RUN; then
        gum style --foreground 214 --bold --margin "1 0" \
            "DRY-RUN MODE — nothing will be installed."
    fi

    gum confirm "Begin?" || { log_info "aborted at welcome"; exit 0; }
}
