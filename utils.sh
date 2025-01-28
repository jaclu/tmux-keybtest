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

# shellcheck source=./tmux-plugin-tools.sh
source "$d_tkbtst_location"/tmux-plugin-tools.sh

#
#  tmux conf that will be used
#
# shellcheck disable=SC2034
tmux_conf="$d_tkbtst_location"/keybtest.conf

# location for socet files
d_tmp="${TMPDIR:-/tmp}"

# shellcheck disable=SC2154
socket_name="$(basename "$(echo "$TMUX" | cut -d, -f 1)")"

f_mouse_status="$d_tmp/tmux-keybtest-$socket_name-mouse-status"
f_mouse_display_timer="$d_tmp/tmux-keybtest-$socket_name-display_timer"
