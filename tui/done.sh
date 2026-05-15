# tui/done.sh — closing screen + neofetch victory lap.

screen_done() {
    clear
    gum_header "All done"

    local lines=()
    local x
    if (( ${#INSTALL_OK[@]} > 0 )); then
        lines+=("$(gum style --foreground 82 --bold "${#INSTALL_OK[@]} installed:")")
        for x in "${INSTALL_OK[@]}"; do lines+=("  ✓ $x"); done
        lines+=("")
    fi
    if (( ${#INSTALL_MANUAL[@]} > 0 )); then
        lines+=("$(gum style --foreground 39 --bold "${#INSTALL_MANUAL[@]} manual (browser opened — finish in GUI):")")
        for x in "${INSTALL_MANUAL[@]}"; do lines+=("  ⇲ $x"); done
        lines+=("")
    fi
    if (( ${#INSTALL_SKIPPED[@]} > 0 )); then
        lines+=("$(gum style --foreground 240 --bold "${#INSTALL_SKIPPED[@]} skipped:")")
        for x in "${INSTALL_SKIPPED[@]}"; do lines+=("  ↷ $x"); done
        lines+=("")
    fi
    if (( ${#INSTALL_FAILED[@]} > 0 )); then
        lines+=("$(gum style --foreground 196 --bold "${#INSTALL_FAILED[@]} failed:")")
        for x in "${INSTALL_FAILED[@]}"; do lines+=("  ✗ $x"); done
    else
        lines+=("$(gum_ok 'no failures.')")
    fi
    gum_box "${lines[@]}"

    if command -v neofetch >/dev/null 2>&1; then
        echo
        neofetch
    fi

    if $DRY_RUN; then
        log_info "dry-run complete — nothing changed."
        return 0
    fi

    if gum confirm "Reboot now? (recommended after kernel / driver updates)"; then
        sudo reboot
    fi
}
