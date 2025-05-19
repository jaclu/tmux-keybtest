#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#
#   Creates a tmux config for testing what keys can be used, then runs it.
#
#   Not directly keyboard related, but since mouse-events also handle the same
#   modifiers, it kind of makes sense to test it here. Enable with option: -m
#
#   to kill any stray sessions: pkill -f ' \-L keybtest'
#
d_tkbtst_location="$(dirname "$(realpath "$0")")"
source "$d_tkbtst_location"/utils.sh

echo
echo "Run with -m to also capture mouse events"
echo

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
