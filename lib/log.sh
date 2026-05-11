# lib/log.sh — small logging helpers
# sourced by install.sh and every other lib/* and apps/* file.

# colors only when stdout is a tty
if [[ -t 1 ]]; then
    _C_BLUE=$'\e[38;5;39m'
    _C_GREEN=$'\e[38;5;82m'
    _C_ORANGE=$'\e[38;5;214m'
    _C_RED=$'\e[38;5;196m'
    _C_GREY=$'\e[38;5;240m'
    _C_WHITE=$'\e[38;5;255m'
    _C_RESET=$'\e[0m'
else
    _C_BLUE= _C_GREEN= _C_ORANGE= _C_RED= _C_GREY= _C_WHITE= _C_RESET=
fi

log_info()    { printf '%s· %s%s\n' "$_C_BLUE"   "$*" "$_C_RESET"; }
log_success() { printf '%s✓ %s%s\n' "$_C_GREEN"  "$*" "$_C_RESET"; }
log_warn()    { printf '%s! %s%s\n' "$_C_ORANGE" "$*" "$_C_RESET" >&2; }
log_error()   { printf '%s✗ %s%s\n' "$_C_RED"    "$*" "$_C_RESET" >&2; }
log_skip()    { printf '%s↷ %s%s\n' "$_C_GREY"   "$*" "$_C_RESET"; }
log_step()    { printf '\n%s━━ %s ━━%s\n' "$_C_BLUE" "$*" "$_C_RESET"; }
