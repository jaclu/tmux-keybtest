#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#
#   Creates a tmux config keybtest.conf, then runs it.
#
#   to kill all stray sessions: pkill -f ' \-L keybtest'
#
d_tkbtst_location="$(dirname "$(realpath "$0")")"
source "$d_tkbtst_location"/utils.sh

# Generate fresh tmux conf, to ensure it matches the installed version
"$d_tkbtst_location"/generate_tmux_conf.sh "$1" || {
    echo "ERROR: generation of $tmux_conf failed!"
    exit 1
}

#
# use pid of this script to make socket unique. This allows more than one
# terminal to run this at the same time independently.
#
# tmux -L keybtest-$$ -f "$d_tkbtst_location"/tmux-keybtest.conf
$TMUX_BIN -L keybtest-$$ -f "$tmux_conf"
