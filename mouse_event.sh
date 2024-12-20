#!/bin/sh

#
# Displays mouse event after 1 second, replacing mount event to be displayed
# with the one from the latest call of this.
# This is needed since some evenets like double & triple click generates
# multiple events
#

d_tkbtst_location="$(realpath "$(dirname -- "$0")")"

# shellcheck source=/dev/null
. "$d_tkbtst_location"/utils.sh

#tmux display-message -p "$1"
#cleanup_tmp_files
#exit 0

# shellcheck disable=SC2154
echo "$1" >"$f_mouse_status"
# shellcheck disable=SC2154
[ -f "$f_mouse_display_timer" ] && exit 0
touch "$f_mouse_display_timer"

sleep 0.8
tmux display-message -p "$(cat "$f_mouse_status")"
cleanup_tmp_files

