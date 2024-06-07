#!/bin/sh

D_TKT_BASE_PATH="$(realpath -- "$(dirname -- "$0")")"

#
# use pid of this script to make socket unique. This allows more than one
# terminal to run this at the same time independently.
#
tmux -L keybtest-$$ -f "$D_TKT_BASE_PATH"/tmux-keybtest.conf
