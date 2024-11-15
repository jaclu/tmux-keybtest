#!/bin/sh
# Always sourced file - Fake bang path to help editors & linters
d_tmp="${TMPDIR:-/tmp}"

# shellcheck disable=SC2154
socket_name="$(basename "$(echo "$TMUX" | cut -d, -f 1)")"

f_mouse_status="$d_tmp/tmux-keybtest-$socket_name-mouse-status"
f_mouse_display_timer="$d_tmp/tmux-keybtest-$socket_name-display_timer"

cleanup_tmp_files() {
    rm -f "$f_mouse_status" "$f_mouse_display_timer"
}
