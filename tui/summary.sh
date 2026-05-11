# tui/summary.sh — show the full plan, last chance to back out.

screen_summary() {
    clear
    gum_header "Summary"

    if (( ${#APPS_TO_INSTALL[@]} == 0 )); then
        gum_warn_box "Nothing selected — there's nothing to do."
        gum confirm "Quit?" && exit 0
        return 1
    fi

    local lines=("Profiles: ${SELECTED_PROFILES[*]}" "")
    lines+=("$(gum style --foreground 39 --bold "${#APPS_TO_INSTALL[@]} app(s) queued:")")

    local id name
    for id in "${APPS_TO_INSTALL[@]}"; do
        name="APP_${id}_NAME"; name="${!name}"
        lines+=("  · $name")
    done

    if $DRY_RUN; then
        lines+=("" "$(gum_warn 'DRY-RUN: nothing will actually install.')")
    fi

    gum_box "${lines[@]}"

    if ! gum confirm "Proceed with install?"; then
        log_info "aborted at summary"
        exit 0
    fi
}
