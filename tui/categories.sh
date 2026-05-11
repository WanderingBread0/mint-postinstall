# tui/categories.sh — per-category multi-select. Profile defaults pre-checked.
#
# APPS_TO_INSTALL is the canonical run list; categories.sh seeds it from the
# user's selections in each section. extras.sh later refines without rebuilding.

APPS_TO_INSTALL=()

# section "title" id-list-var-name
_section() {
    local title="$1"
    local -n ids="$2"   # nameref to e.g. BROWSERS_IDS

    clear
    gum_header "$title"

    # Filter the catalog to apps whose PROFILES intersect with the user's
    # selected profiles, then build labels in catalog order. This is what
    # drops e.g. Discord from messengers and the whole Gaming section when
    # only 'privacy' is chosen.
    local filtered_ids=()
    local id
    for id in "${ids[@]}"; do
        app_matches_selected_profiles "$id" && filtered_ids+=("$id")
    done

    if (( ${#filtered_ids[@]} == 0 )); then
        # Whole category is irrelevant for the current profile mix — skip it.
        return 0
    fi

    local labels=() defaults=()
    local name desc score label
    for id in "${filtered_ids[@]}"; do
        name="APP_${id}_NAME";   name="${!name}"
        desc="APP_${id}_DESC";   desc="${!desc}"
        local score_var="APP_${id}_SCORE"
        score="${!score_var:-}"
        if [[ -n "$score" ]]; then
            label="$(printf '%-22s %s  %s' "$name" "$score" "$desc")"
        else
            label="$(printf '%-22s %s' "$name" "$desc")"
        fi
        labels+=("$label")
        if app_is_default_for_selected_profiles "$id"; then
            defaults+=("$label")
        fi
    done

    if (( ${#labels[@]} == 0 )); then return 0; fi

    local sel_csv=""
    if (( ${#defaults[@]} > 0 )); then
        # gum --selected takes comma-separated list
        printf -v sel_csv '%s,' "${defaults[@]}"
        sel_csv="${sel_csv%,}"
    fi

    local chosen=()
    mapfile -t chosen < <(
        gum choose \
            --no-limit \
            --height 20 \
            --header "Select apps to install (Space toggles, Enter confirms)" \
            --selected-prefix "[x] " \
            --unselected-prefix "[ ] " \
            --selected "$sel_csv" \
            -- "${labels[@]}"
    )

    # Map chosen labels back to ids (using filtered_ids since labels[] was
    # built from that) and append uniquely.
    local c i
    for c in "${chosen[@]}"; do
        for ((i=0; i<${#labels[@]}; i++)); do
            if [[ "${labels[$i]}" == "$c" ]]; then
                _add_to_install "${filtered_ids[$i]}"
                break
            fi
        done
    done
}

_add_to_install() {
    local id="$1" existing
    for existing in "${APPS_TO_INSTALL[@]}"; do
        [[ "$existing" == "$id" ]] && return 0
    done
    APPS_TO_INSTALL+=("$id")
}

_remove_from_install() {
    local id="$1" new=() existing
    for existing in "${APPS_TO_INSTALL[@]}"; do
        [[ "$existing" == "$id" ]] || new+=("$existing")
    done
    APPS_TO_INSTALL=("${new[@]}")
}

_install_contains() {
    local id="$1" existing
    for existing in "${APPS_TO_INSTALL[@]}"; do
        [[ "$existing" == "$id" ]] && return 0
    done
    return 1
}

screen_categories() {
    _section "Browsers"          BROWSERS_IDS
    _section "Proton Suite"      PROTON_IDS
    _section "Messengers"        MESSENGERS_IDS
    _section "Notes"             NOTES_IDS
    _section "Gaming"            GAMING_IDS
    _section "Terminal & Shell"  TERMINAL_IDS
    _section "Utilities"         UTILITIES_IDS
    _section "Dev Tools"         DEV_IDS
    _section "Media & Creative"  MEDIA_IDS
}
