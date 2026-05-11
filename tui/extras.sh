# tui/extras.sh — "show me everything" full-catalog browse.
#
# Unlike the original sketch, this does NOT rebuild APPS_TO_INSTALL from
# scratch. It opens the entire catalog with the current selections pre-checked,
# preserves selection order, and detects pairwise conflicts before returning.

# ALL_IDS is defined in install.sh after the apps/* files are sourced.

# Pairs of apps where having both queued is probably a mistake.
CONFLICT_PAIRS=(
    "firefox:librewolf"      # two Firefox-derived browsers
    "telegram:signal"        # not a hard conflict, just FYI — disabled below
)
# Only the first pair is treated as a warn. Trim the array to keep it real.
CONFLICT_PAIRS=("firefox:librewolf")

screen_extras() {
    clear
    gum_header "Extras — Full Catalog"

    gum_box \
        "Browse every app the script knows about." \
        "Currently selected apps stay checked; toggle any others on/off." \
        "" \
        "$(gum_muted "Tip: type / to filter the list.")"

    # Build labels in original catalog order, mark current selections
    local labels=() preselected=()
    local id name desc score label
    for id in "${ALL_IDS[@]}"; do
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
        if _install_contains "$id"; then
            preselected+=("$label")
        fi
    done

    local sel_csv=""
    if (( ${#preselected[@]} > 0 )); then
        printf -v sel_csv '%s,' "${preselected[@]}"
        sel_csv="${sel_csv%,}"
    fi

    local chosen=()
    mapfile -t chosen < <(
        gum choose \
            --no-limit \
            --height 25 \
            --header "Toggle apps (Space) — Enter when done. / filters." \
            --selected-prefix "[x] " \
            --unselected-prefix "[ ] " \
            --selected "$sel_csv" \
            -- "${labels[@]}"
    )

    # Translate back to ids — preserves catalog order.
    local new_install=() i c match
    for ((i=0; i<${#labels[@]}; i++)); do
        match=false
        for c in "${chosen[@]}"; do
            if [[ "${labels[$i]}" == "$c" ]]; then match=true; break; fi
        done
        $match && new_install+=("${ALL_IDS[$i]}")
    done
    APPS_TO_INSTALL=("${new_install[@]}")

    _check_conflicts
}

# Warn (but don't block) when conflicting apps are both queued.
_check_conflicts() {
    local pair a b a_name b_name warned=false
    for pair in "${CONFLICT_PAIRS[@]}"; do
        a="${pair%%:*}"; b="${pair##*:}"
        if _install_contains "$a" && _install_contains "$b"; then
            a_name="APP_${a}_NAME"; a_name="${!a_name}"
            b_name="APP_${b}_NAME"; b_name="${!b_name}"
            warned=true
            gum_warn_box \
                "$(gum style --foreground 214 --bold "conflict: $a_name + $b_name")" \
                "" \
                "Both are queued. They overlap heavily — most users want one or the other." \
                "Leaving both in place; remove one in Extras if that's not what you wanted."
        fi
    done
    $warned && sleep 1
}
