#!/bin/sh

D_TKT_BASE_PATH="$(realpath -- "$(dirname -- "$0")")"

tmux -L keybtest -f "$D_TKT_BASE_PATH"/tmux-keybtest.conf
