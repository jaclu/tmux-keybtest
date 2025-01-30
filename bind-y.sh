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
# $TMUX_BIN bind -n M-y display-message "m-y"
# $TMUX_BIN bind -n C-y display-message "c-y"
# $TMUX_BIN bind -n C-M-y display-message "c-m-y"

# $TMUX_BIN bind -n Y display-message "Y^"
# $TMUX_BIN bind -n M-Y display-message "M-Y"

# sends ^Y
$TMUX_BIN bind -n C-Y display-message "C-Y"
$TMUX_BIN bind -n C-M-Y display-message "M-C-Y"

# sends ^Y
$TMUX_BIN bind -n C-S-Y display-message "C-S-Y"
# sends ^[^Y
$TMUX_BIN bind -n C-M-S-Y display-message "M-C-S-Y"

#
#
$TMUX_BIN display "Y testing setup!"

#
#   iTerm2 Sends ^Y for C-Y so not a test candidate
#
#   Kitty
#   c-y: ^Y
#   C-Y: ^[[121;6u
#
#   3.5a    Neiter C-Y nor C-S-Y sequences are parsed by tmux
#           C-S-Y does not seem to be parsed by tmux lowercase dito not overriden
#   3.2a    C-Y M-C-Y overrides lowercase, but does not trigger action itself
#           C-S-Y / M-C-S-Y parsed and does not alter c-y
#   3.1     uppercase Ctrl keyes ignored by tmux
#
#   Ghostty  <=====
#   c-y: ^Y
#   C-Y: ^[[121;6u
#
#   3.5a    ignores C-S-Y / M-C-S-Y -  C-Y M-C-Y are parsed depending on keyb settings
#   3.2a    C-Y M-C-Y overrides lowercase, but does not trigger action itself
#           C-S-Y / M-C-S-Y parsed and does not alter c-y
#   3.1     uppercase Ctrl keyes ignored by tmux
