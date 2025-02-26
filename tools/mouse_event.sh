#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#
#   Not used ATM
#
# Displays mouse event after 1 second, replacing mount event to be displayed
# with the one from the latest call of this.
# This is needed since some evenets like double & triple click generates
# multiple events
#

cleanup_tmp_files() {
    rm -f "$f_mouse_status" "$f_mouse_display_timer"
}

d_tkbtst_location="$(dirname "$(realpath "$0")")"

# shellcheck source=utils.sh
. "$d_tkbtst_location"/utils.sh

d_tmp="${TMPDIR:-/tmp}"
socket_name="$(basename "$(echo "$TMUX_BIN" | cut -d, -f 1)")"
f_mouse_status="$d_tmp/tmux-keybtest-$socket_name-mouse-status"
f_mouse_display_timer="$d_tmp/tmux-keybtest-$socket_name-display_timer"

echo "$1" >"$f_mouse_status"
[[ -f "$f_mouse_display_timer" ]] && exit 0
touch "$f_mouse_display_timer"

sleep 0.1
$TMUX_BIN display-message "$(cat "$f_mouse_status")"
cleanup_tmp_files
