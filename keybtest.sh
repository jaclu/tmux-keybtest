#!/bin/sh

d_tkbtst_location="$(realpath "$(dirname -- "$0")")"

# . "$d_tkbtst_location"/utils.sh
# cleanup_tmp_files

#
# use pid of this script to make socket unique. This allows more than one
# terminal to run this at the same time independently.
#
export d_tkbtst_location

tmux -L keybtest-$$ -f "$d_tkbtst_location"/tmux-keybtest.conf
