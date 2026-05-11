# tui/execute.sh — walk APPS_TO_INSTALL and run each install_<id>.

screen_execute() {
    clear
    gum_header "Installing"

    log_info "running ${#APPS_TO_INSTALL[@]} installer(s)..."

    local id total="${#APPS_TO_INSTALL[@]}" n=0
    for id in "${APPS_TO_INSTALL[@]}"; do
        n=$((n + 1))
        local fn="install_${id}"
        local name_var="APP_${id}_NAME"; local name="${!name_var:-$id}"
        if ! declare -F "$fn" >/dev/null; then
            log_error "no installer function found: $fn (skipping $name)"
            INSTALL_FAILED+=("$name")
            continue
        fi
        log_step "[$n/$total] $name"
        # Run installer; don't let one failure abort the whole batch.
        "$fn" || true
    done
}
