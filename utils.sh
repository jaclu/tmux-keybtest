#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#
#   Common utils
#

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

#
#  provides tmux_vers_ok
#
# shellcheck source=/dev/null
source "$d_tkbtst_location"/tmux-plugin-tools.sh

#
#  tmux conf that will be used
#
# shellcheck disable=SC2034
tmux_conf="$d_tkbtst_location"/keybtest.conf

#
#  Mouse event helper
#

# shellcheck disable=SC2034
f_mouse_event="$d_tkbtst_location"/tools/mouse_event.sh
