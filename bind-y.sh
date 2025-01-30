#!/bin/sh

# 3.5a
#   iterm2  ok  any -S-Y            Ignores C-Y M-Y C-M-Y
#   kitty   ok  M-Y                 Ignores any other -Y combo
#   ghostty ok  C-Y M-Y & C-M-Y     Ignores any -S-Y combo

# 3.4
#   iterm2  leak C-y C-M-y          Ignores M-y
#   kitty   ok  M-Y C-S-Y C-M-S-Y   Ignores C-Y M-S-Y C-M-Y

# shellcheck disable=SC2154
$TMUX_BIN bind -n y display-message "y"
$TMUX_BIN bind -n Y display-message "Y"

$TMUX_BIN bind -n C-y display-message "C-y"
$TMUX_BIN bind -n C-S-Y display-message "C-S-Y"
# $TMUX_BIN bind -n C-Y display-message "C-Y"

$TMUX_BIN bind -n M-y display-message "M-y"
$TMUX_BIN bind -n M-Y display-message "M-Y"

$TMUX_BIN bind -n C-M-y display-message "C-M-y"
$TMUX_BIN bind -n C-M-S-Y display-message "C-M-S-Y"
# $TMUX_BIN bind -n C-M-Y display-message "C-M-Y"
