#!/usr/bin/env bash
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#
#  1. Set tmux version
#  2. generate a matching tmux.conf
#  3. run keybtest.sh
#

d_tkbtst_location="$(realpath "$(dirname -- "$0")")"
source "$d_tkbtst_location"/utils.sh

[[ -z "$1" ]] && {
    echo "ERROR: tmux vers must be given as param!"
    exit 1
}

#
#  First cd to proj folder, in-case this was run from somewhere else,
#  to make sure no local tmux version is set at a random place
#
cd "$d_tkbtst_location" || exit 1

asdf local tmux "$1" && ./keybtest.sh
