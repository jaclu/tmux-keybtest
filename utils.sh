#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#

get_digits_from_string() {
    # this is used to get "clean" integer version number. Examples:
    # `tmux 1.9` => `19`
    # `1.9a`     => `19`
    local string="$1"
    local only_digits no_leading_zero

    only_digits="$(echo "$string" | tr -dC '[:digit:]')"
    no_leading_zero=${only_digits#0}
    echo "$no_leading_zero"
}

get_tmux_vers() {
    #
    #  Variables provided:
    #   tmux_vers - version of tmux used
    #
    tmux_vers="$($TMUX_BIN -V | cut -d' ' -f2)"

    # Filter out devel prefix and release candidate suffix
    case "$tmux_vers" in
    next-*)
        # Remove "next-" prefix
        tmux_vers="${tmux_vers#next-}"
        ;;
    *-rc*)
        # Remove "-rcX" suffix, otherwise the number would mess up version
        # 3.4-rc2 would be read as 342
        tmux_vers="${tmux_vers%-rc*}"
        ;;
    *) ;;
    esac
}

tmux_vers_compare() {
    #
    #  This returns true if v_comp <= v_ref
    #  If only one param is given it is compared vs version of running tmux
    #
    local v_comp="$1"
    local v_ref="${2:-$tmux_vers}"
    local i_comp i_ref

    i_comp=$(get_digits_from_string "$v_comp")
    i_ref=$(get_digits_from_string "$v_ref")

    [[ "$i_comp" -le "$i_ref" ]]
}

cleanup_tmp_files() {
    rm -f "$f_mouse_status" "$f_mouse_display_timer"
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

get_tmux_vers

# shellcheck disable=SC2034
tmux_conf="$d_tkbtst_location"/keybtest.conf

# Always sourced file - Fake bang path to help editors & linters
d_tmp="${TMPDIR:-/tmp}"

# shellcheck disable=SC2154
socket_name="$(basename "$(echo "$TMUX" | cut -d, -f 1)")"

f_mouse_status="$d_tmp/tmux-keybtest-$socket_name-mouse-status"
f_mouse_display_timer="$d_tmp/tmux-keybtest-$socket_name-display_timer"
