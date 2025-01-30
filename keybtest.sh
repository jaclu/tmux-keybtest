#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#

d_tkbtst_location="$(dirname "$(realpath "$0")")"
source "$d_tkbtst_location"/utils.sh

cleanup_tmp_files

# Generate fresh tmux conf, to ensure it matches the installed version
"$d_tkbtst_location"/generate_tmux_conf.sh

#
# use pid of this script to make socket unique. This allows more than one
# terminal to run this at the same time independently.
#
# tmux -L keybtest-$$ -f "$d_tkbtst_location"/tmux-keybtest.conf
$TMUX_BIN -L keybtest-$$ -f "$tmux_conf"
