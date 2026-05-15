# lib/install.sh — generic installers, one per install method.
# every function honours $DRY_RUN and never aborts the parent on failure.

# track results so summary screen can show what worked / failed
INSTALL_FAILED=()
INSTALL_OK=()
INSTALL_SKIPPED=()
INSTALL_MANUAL=()

_record_ok()      { INSTALL_OK+=("$1");      log_success "$1 installed"; }
_record_skip()    { INSTALL_SKIPPED+=("$1"); log_skip    "$1 skipped (already present)"; }
_record_fail()    { INSTALL_FAILED+=("$1");  log_error   "$1 failed"; }
_record_manual()  { INSTALL_MANUAL+=("$1");  log_info    "$1 — manual step required"; }
_record_dryrun()  { INSTALL_SKIPPED+=("$1"); log_skip    "[dry-run] would install $1"; }

# --- helpers -----------------------------------------------------------------

# spin "label" cmd args...  (silent on success, dumps log on failure)
_spin() {
    local label="$1"; shift
    local log; log="$(mktemp)"
    if command -v gum >/dev/null 2>&1; then
        gum spin --spinner dot --title "$label" -- bash -c "$* >\"$log\" 2>&1"
        local rc=$?
    else
        bash -c "$* >\"$log\" 2>&1"
        local rc=$?
    fi
    if (( rc != 0 )); then
        log_error "$label failed (rc=$rc)"
        sed 's/^/    /' "$log" >&2
    fi
    rm -f "$log"
    return $rc
}

_apt_has() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"; }
_flatpak_has() { flatpak info "$1" >/dev/null 2>&1; }

# --- public installers -------------------------------------------------------

# install_apt "Display Name" "package-name" ["package-name-2" ...]
install_apt() {
    local name="$1"; shift
    if $DRY_RUN; then _record_dryrun "$name (apt: $*)"; return 0; fi

    local missing=()
    for p in "$@"; do _apt_has "$p" || missing+=("$p"); done
    if (( ${#missing[@]} == 0 )); then _record_skip "$name"; return 0; fi

    if _spin "installing $name" "sudo apt-get install -y ${missing[*]}"; then
        _record_ok "$name"
    else
        _record_fail "$name"
        return 1
    fi
}

# install_flatpak "Display Name" "org.app.Id"
install_flatpak() {
    local name="$1" id="$2"
    if $DRY_RUN; then _record_dryrun "$name (flatpak: $id)"; return 0; fi

    if _flatpak_has "$id"; then _record_skip "$name"; return 0; fi

    if _spin "installing $name" "flatpak install -y --noninteractive flathub $id"; then
        _record_ok "$name"
    else
        _record_fail "$name"
        return 1
    fi
}

# install_deb_url "Display Name" "https://...deb"
install_deb_url() {
    local name="$1" url="$2"
    if $DRY_RUN; then _record_dryrun "$name (deb: $url)"; return 0; fi

    local tmp; tmp="$(mktemp --suffix=.deb)"
    if _spin "downloading $name" "curl -fsSL '$url' -o '$tmp'" \
       && _spin "installing $name"  "sudo apt-get install -y '$tmp'"; then
        _record_ok "$name"
        rm -f "$tmp"
    else
        _record_fail "$name"
        rm -f "$tmp"
        return 1
    fi
}

# install_repo "Display Name" key_url key_path repo_line repo_file package
install_repo() {
    local name="$1" key_url="$2" key_path="$3" repo_line="$4" repo_file="$5" pkg="$6"
    if $DRY_RUN; then _record_dryrun "$name (repo: $pkg)"; return 0; fi

    if _apt_has "$pkg"; then _record_skip "$name"; return 0; fi

    sudo install -d -m 0755 "$(dirname "$key_path")"

    # Always (re)write the keyring through `sudo tee` and chmod 0644.
    # `sudo gpg --dearmor -o /path` would create the file mode 0600, which
    # apt's signed-by mechanism rejects (the _apt user can't read it).
    # That silently breaks Signal, Vivaldi, VS Code, and Opera GX repos.
    _spin "fetching $name key" \
        "curl -fsSL '$key_url' | gpg --dearmor | sudo tee '$key_path' >/dev/null && sudo chmod 0644 '$key_path'" \
        || { _record_fail "$name"; return 1; }

    echo "$repo_line" | sudo tee "$repo_file" >/dev/null
    _spin "apt update for $name" "sudo apt-get update -qq" \
        || { _record_fail "$name"; return 1; }

    if _spin "installing $name" "sudo apt-get install -y $pkg"; then
        _record_ok "$name"
    else
        _record_fail "$name"
        return 1
    fi
}

# install_script "Display Name" custom_function_name
install_script() {
    local name="$1" fn="$2"
    if $DRY_RUN; then _record_dryrun "$name (script: $fn)"; return 0; fi

    if "$fn"; then
        _record_ok "$name"
    else
        _record_fail "$name"
        return 1
    fi
}

# manual_install "Display Name" "url" "warning-text"
# never runs anything; opens browser and logs the warning.
manual_install() {
    local name="$1" url="$2" msg="$3"
    if command -v gum >/dev/null 2>&1; then
        gum_warn_box \
            "$(gum style --foreground 214 --bold "manual install: $name")" \
            "" \
            "$msg" \
            "" \
            "$(gum_muted "opening: $url")"
    else
        log_warn "manual install required: $name — $url"
        log_warn "$msg"
    fi
    if $DRY_RUN; then _record_dryrun "$name (manual)"; return 0; fi
    command -v xdg-open >/dev/null 2>&1 && xdg-open "$url" >/dev/null 2>&1 &
    _record_manual "$name"
}

# ensure_flathub — once per run, sets up flatpak + flathub remote
_FLATHUB_READY=false
ensure_flathub() {
    $_FLATHUB_READY && return 0
    if $DRY_RUN; then
        log_skip "[dry-run] would ensure flatpak + flathub"
        _FLATHUB_READY=true
        return 0
    fi
    _apt_has flatpak || _spin "installing flatpak" "sudo apt-get install -y flatpak" \
        || { log_error "could not install flatpak"; return 1; }
    flatpak remote-list 2>/dev/null | grep -q '^flathub' \
        || _spin "adding flathub remote" \
            "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo" \
        || { log_error "could not add flathub remote"; return 1; }
    _FLATHUB_READY=true
}
