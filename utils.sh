#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#

cleanup_tmp_files() {
    rm -f "$f_mouse_status" "$f_mouse_display_timer"
}

tmux_vers_ok() {
    # Function Purpose:
    # This function checks if the running version of tmux is at least the specified version.
    #
    get_digits_from_string() {
        local i

        i="$(echo "$1" | tr -cd '0-9')"
        echo "$i"
    }

    get_suffix() {
        echo "${1//[^a-zA-Z]*([0-9])([a-zA-Z]*)/\2}"
    }

    local v_comp i_comp suffix_comp

    if [[ -z "$tmux_vers" ]]; then
        # First call: retrieves and stores the current tmux version for future use
        tmux_vers="$(tmux -V | cut -d' ' -f2)"
        _tmux_vers_i="$(get_digits_from_string "$tmux_vers")"
        _tmux_vers_suffix="$(get_suffix "$tmux_vers")"
    fi

    v_comp="$1"
    i_comp="$(get_digits_from_string "$v_comp")"

    # if numeric is less than reference then certain fail
    [[ "$i_comp" -lt "$_tmux_vers_i" ]] && {
        # echo "OK - numerically smaller"
        return 0
    }
    # if numeric is greater than reference then certain fail
    [[ "$i_comp" -gt "$_tmux_vers_i" ]] && {
        # echo "Fail - numerically larger: $v_comp"
        return 1
    }

    # if numerical version is same, suffix sorting decides
    suffix_comp="$(get_suffix "$v_comp")"
    [[ "$suffix_comp" = "$_tmux_vers_suffix" ]] ||
        [[ "$(printf '%s\n%s\n' "$suffix_comp" "$_tmux_vers_suffix" |
            LC_COLLATE=C sort | head -n 1)" = "$suffix_comp" ]] && return 0

    # echo "Suffix Fail: $v_comp > $tmux_vers"
    return 1
}

#===============================================================
#
#   Main
#
#===============================================================

[[ -z "$d_tkbtst_location" ]] && {
    echo "ERROR: d_tkbtst_location undefined in: $0"
    exit 1
}

if [[ -f "$d_tkbtst_location"/.tool-versions ]]; then
    # local asdf version defined, ignore potential previous definition of TMUX_CONF
    TMUX_BIN="tmux"
else
    # Honour it if defined
    [[ -z "$TMUX_BIN" ]] && TMUX_BIN="tmux"
fi

# shellcheck disable=SC2034
tmux_conf="$d_tkbtst_location"/keybtest.conf

# Always sourced file - Fake bang path to help editors & linters
d_tmp="${TMPDIR:-/tmp}"

# shellcheck disable=SC2154
socket_name="$(basename "$(echo "$TMUX" | cut -d, -f 1)")"

f_mouse_status="$d_tmp/tmux-keybtest-$socket_name-mouse-status"
f_mouse_display_timer="$d_tmp/tmux-keybtest-$socket_name-display_timer"
