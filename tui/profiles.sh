# tui/profiles.sh — stackable multi-select profile picker.
#
# The historical bug here was `SELECTED_PROFILES=$(gum choose ...)` followed
# by a pipe into `while read`, which loses the array because the loop runs in
# a subshell. We use `mapfile < <(...)` so the parent shell owns the array.

PROFILES_AVAILABLE=(privacy gaming dev content general)
SELECTED_PROFILES=()

screen_profiles() {
    clear
    gum_header "Profiles"

    gum_box \
        "Profiles are stackable — pick as many as you want." \
        "" \
        "  🔒 privacy  ProtonVPN, Signal, LibreWolf, Standard Notes, ClamTK" \
        "  🎮 gaming   Steam, Lutris, Discord, Opera GX" \
        "  💻 dev      VS Code, Tmux, Obsidian, Zsh + Oh My Zsh" \
        "  🎬 content  KDenlive, OBS, GIMP" \
        "  🪟 general  baseline desktop apps (VLC, Flameshot, Firefox, …)" \
        "" \
        "$(gum_muted "Space toggles, Enter confirms, type / to filter.")"

    # Use mapfile to read array safely from process substitution.
    # --no-limit makes it multi-select; --selected primes 'general' so empty
    # selection still yields something sensible.
    mapfile -t SELECTED_PROFILES < <(
        gum choose \
            --no-limit \
            --header "Select profiles (Space = toggle, Enter = confirm)" \
            --cursor "> " \
            --selected-prefix "[x] " \
            --unselected-prefix "[ ] " \
            --selected "general" \
            -- privacy gaming dev content general
    )

    if (( ${#SELECTED_PROFILES[@]} == 0 )); then
        log_warn "no profiles selected — defaulting to 'general'"
        SELECTED_PROFILES=(general)
    fi

    log_info "profiles: ${SELECTED_PROFILES[*]}"
}

# profile_active "privacy"  -> 0 if selected, 1 otherwise
profile_active() {
    local needle="$1" p
    for p in "${SELECTED_PROFILES[@]}"; do
        [[ "$p" == "$needle" ]] && return 0
    done
    return 1
}

# app_is_default_for_selected_profiles app_id  -> 0 if YES
app_is_default_for_selected_profiles() {
    local id="$1"
    local arr_name="APP_${id}_DEFAULT_IN[@]"
    local d p
    for d in "${!arr_name}"; do
        for p in "${SELECTED_PROFILES[@]}"; do
            [[ "$d" == "$p" ]] && return 0
        done
    done
    return 1
}
