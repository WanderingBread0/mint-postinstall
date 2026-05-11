# tui/mode.sh — how does the user want to choose what to install?
#
# Three modes:
#   defaults   — auto-fill APPS_TO_INSTALL with everything pre-checked for
#                the selected profiles, jump straight to summary
#   customize  — current behaviour: walk category by category, then extras
#   full       — pre-seed defaults, then open the full catalog (extras)
#                so the user can see and toggle every option on one screen

INSTALL_MODE=""

screen_mode() {
    clear
    gum_header "How do you want to choose?"

    # Count what the defaults would install for the chosen profiles, so the
    # "Install defaults now" option carries a real number instead of vibes.
    local default_count=0 id
    for id in "${ALL_IDS[@]}"; do
        app_matches_selected_profiles "$id" || continue
        if app_is_default_for_selected_profiles "$id"; then
            default_count=$((default_count + 1))
        fi
    done

    gum_box \
        "Profiles: ${SELECTED_PROFILES[*]}" \
        "" \
        "  · Install defaults now — ${default_count} app(s), no questions" \
        "  · Customize per category — only the categories relevant to your" \
        "    profiles, defaults pre-checked" \
        "  · See full catalog — one screen, every app, toggle anything"

    local choice
    choice="$(
        gum choose \
            --height 12 \
            --header "Pick a setup style" \
            --cursor "> " \
            -- \
            "Install defaults now (${default_count} apps)" \
            "Customize per category" \
            "See full catalog (one screen)"
    )"

    case "$choice" in
        "Install defaults now"*)        INSTALL_MODE=defaults  ;;
        "Customize per category"*)      INSTALL_MODE=customize ;;
        "See full catalog"*)            INSTALL_MODE=full      ;;
        *)                              INSTALL_MODE=customize ;;
    esac

    log_info "mode: $INSTALL_MODE"
}

# Pre-fill APPS_TO_INSTALL with every app marked DEFAULT_IN for the selected
# profiles. Used by 'defaults' and 'full' modes.
seed_from_defaults() {
    local id
    for id in "${ALL_IDS[@]}"; do
        if app_is_default_for_selected_profiles "$id"; then
            _add_to_install "$id"
        fi
    done
}
