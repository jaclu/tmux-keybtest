#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#

#
#  This will generate a tmux.conf adjusted to the used tmux version
#

writeln() {
    printf "%s\n" "$1" >>"$tmux_conf"
}

header_1() {
    writeln
    writeln "#  --  $1"
}

header_2() {
    writeln
    writeln "#"
    writeln "#  $1"
    writeln "#"
}

header_3() {
    writeln
    writeln
    writeln "#==========================================================="
    writeln "#"
    writeln "#  Segment covering modifier: $1"
    writeln "#"
    writeln "#==========================================================="
}

bind_char() {
    local output="bind -n "

    [[ -z "$1" ]] && {
        echo "ERROR: call to bind_char() with no param"
        exit 1
    }
    case "$2" in
    s | S) output+="'${mod}$1' display-message '${mod}$1'" ;;
    d | D) output+="\"${mod}$1\" display-message \"${mod}$1\"" ;;
    *) output+="${mod}$1 display-message \"${mod}$1\"" ;;
    esac
    writeln "$output"
}

base_conf() {
    writeln "#==========================================================="
    writeln "#"
    writeln "#  Tmux conf for teting keyboard implementation, and what"
    writeln "#  non standard sequences it can generate. - Arrows with modifiers etc"
    writeln "#"
    writeln "#==========================================================="
    writeln ""
    writeln "# Created for tmux version: $tmux_vers"
    writeln ""
    writeln "#"
    writeln "#  Minimal config"
    writeln "#"
    writeln "set-option -g prefix C-x"
    writeln "bind C-c kill-server"
    writeln "set-option -g mouse on"
    writeln "set-option -s escape-time 100"
    writeln "set-option -g display-time 1000"
    writeln "set-option -g visual-bell on"
    writeln "set -g focus-events on"
    tmux_vers_ok 3.2 && writeln "set -g extended-keys on"
    # tmux_vers_ok 2.8 && writeln 'bind Any display "Not defined"'
    tmux_vers_ok 2.9 && {
        writeln
        writeln "#"
        writeln "#  Display some hints in status bar left row 2 & 3"
        writeln "#"
        writeln "set-option -g status 3"
        writeln "set-option -g status-format[1] 'Displays keys and mouse events recognized by tmux in status-bar'"
        writeln "set-option -g status-format[2] 'To exit press C-x then C-c. To test C-x press it twice'"
    }

    writeln
    writeln "#"
    writeln "# Display prefix key pressed in Status bar right"
    writeln "#"
    writeln "set-option -g status-right-length 0"
    writeln "set-option -g status-right '#{?client_prefix,Prefix #[fg=colour231]#[bg=colour04]C-x#[default] - Press C-c to exit,}'"
    writeln "run-shell -b 'sleep 0.5 ; tmux send-keys \"showkey -a\" C-M'"
}

mouse_event_via_script() {
    # Doesn't work right now, using mouse_events() instead

    header_2 "Mouse"
    writeln "bind -n '${mod}WheelUpPane' run-shell -b '\$f_mouse_event ${mod}WheelUpPane'"
    writeln "bind -n '${mod}WheelDownPane' run-shell -b '\$f_mouse_event ${mod}WheelDownPane'"
    writeln "bind -n '${mod}MouseDown1Pane' run-shell -b '\$f_mouse_event ${mod}MouseDown1Pane'"
    writeln "bind -n '${mod}MouseUp1Pane' run-shell -b '\$f_mouse_event ${mod}MouseUp1Pane'"
    writeln "bind -n '${mod}MouseDrag1Pane' run-shell -b '\$f_mouse_event ${mod}MouseDrag1Pane'"
    writeln "bind -n '${mod}MouseDragEnd1Pane' run-shell -b '\$f_mouse_event ${mod}MouseDragEnd1Pane'"
    writeln "bind -n '${mod}MouseDown2Pane' run-shell -b '\$f_mouse_event ${mod}MouseDown2Pane'"
    writeln "bind -n '${mod}MouseUp2Pane' run-shell -b '\$f_mouse_event ${mod}MouseUp2Pane'"
    writeln "bind -n '${mod}MouseDrag2Pane' run-shell -b '\$f_mouse_event ${mod}MouseDrag2Pane'"
    writeln "bind -n '${mod}MouseDragEnd2Pane' run-shell -b '\$f_mouse_event ${mod}MouseDragEnd2Pane'"
    writeln "bind -n '${mod}MouseDown3Pane' run-shell -b '\$f_mouse_event ${mod}MouseDown3Pane'"
    writeln "bind -n '${mod}MouseUp3Pane' run-shell -b '\$f_mouse_event ${mod}MouseUp3Pane'"
    writeln "bind -n '${mod}MouseDrag3Pane' run-shell -b '\$f_mouse_event ${mod}MouseDrag3Pane'"
    writeln "bind -n '${mod}MouseDragEnd3Pane' run-shell -b '\$f_mouse_event ${mod}MouseDragEnd3Pane'"
    writeln "bind -n '${mod}SecondClick1Pane' run-shell -b '\$f_mouse_event ${mod}SecondClick1Pane'"
    writeln "bind -n '${mod}SecondClick2Pane' run-shell -b '\$f_mouse_event ${mod}SecondClick2Pane'"
    writeln "bind -n '${mod}SecondClick3Pane' run-shell -b '\$f_mouse_event ${mod}SecondClick3Pane'"
    writeln "bind -n '${mod}DoubleClick1Pane' run-shell -b '\$f_mouse_event ${mod}DoubleClick1Pane'"
    writeln "bind -n '${mod}DoubleClick2Pane' run-shell -b '\$f_mouse_event ${mod}DoubleClick2Pane'"
    writeln "bind -n '${mod}DoubleClick3Pane' run-shell -b '\$f_mouse_event ${mod}DoubleClick3Pane'"
    writeln "bind -n '${mod}TripleClick1Pane' run-shell -b '\$f_mouse_event ${mod}TripleClick1Pane'"
    writeln "bind -n '${mod}TripleClick2Pane' run-shell -b '\$f_mouse_event ${mod}TripleClick2Pane'"
    writeln "bind -n '${mod}TripleClick3Pane' run-shell -b '\$f_mouse_event ${mod}TripleClick3Pane'"
}

mouse_events() {
    header_2 "Mouse"
    bind_char WheelUpPane d
    bind_char WheelDownPane d
    bind_char MouseDown1Pane d
    bind_char MouseUp1Pane d
    bind_char MouseDrag1Pane d
    bind_char MouseDragEnd1Pane d
    bind_char MouseDown2Pane d
    bind_char MouseUp2Pane d
    bind_char MouseDrag2Pane d
    bind_char MouseDragEnd2Pane d
    bind_char MouseDown3Pane d
    bind_char MouseUp3Pane d
    bind_char MouseDrag3Pane d
    bind_char MouseDragEnd3Pane d
    bind_char DoubleClick1Pane d
    bind_char DoubleClick2Pane d
    bind_char DoubleClick3Pane d
    bind_char TripleClick1Pane d
    bind_char TripleClick2Pane d
    bind_char TripleClick3Pane d

    tmux_vers_ok 3.2 || return

    bind_char SecondClick1Pane d
    bind_char SecondClick2Pane d
    bind_char SecondClick3Pane d
}

lower_case_chars() {

    case "$mod" in
    S- | C-S- | M-S- | C-M-S-) tmux_vers_ok 3.5 || return ;;
    *) ;;
    esac
    header_1 "Lower Case"
    bind_char a
    bind_char b
    bind_char c
    bind_char d
    bind_char e
    bind_char f
    bind_char g
    bind_char h

    # Messes with Escaoe & Enter on older versions
    case "$mod" in
    C- | C-M-)
        tmux_vers_ok 3.5 && {
            bind_char i
            bind_char m
        }
        ;;
    *) ;;
    esac

    bind_char j
    bind_char k
    bind_char l d
    bind_char n
    bind_char o
    bind_char p d
    bind_char q
    bind_char r
    bind_char s d
    bind_char t
    bind_char u
    bind_char v d
    bind_char w

    case "$mod" in
    C-)
        # Special case bind this to the root table, in order to display prefix
        # on second press
        writeln "bind '${mod}x' display-message '${mod}x'"
        ;;
    *) bind_char x ;;
    esac

    bind_char y
    bind_char z
    bind_char "å"
    bind_char "ä"
    bind_char "ö"

    header_1 "acute accent"
    bind_char "á"
    bind_char "é"
    bind_char "í"
    bind_char "ó"
    bind_char "ú"
    bind_char "ý"
}

upper_case_chars() {

    case "$mod" in
    # C-) return ;;
    *) ;;
    esac

    header_1 "Upper Case"
    bind_char A
    bind_char B
    bind_char C
    bind_char D
    bind_char E
    bind_char F
    bind_char G
    bind_char H

    # Messes with Escaoe & Enter on older versions
    case "$mod" in
    C- | C-M-)
        tmux_vers_ok 3.5 && {
            bind_char I
            bind_char M
        }
        ;;
    *) ;;
    esac

    bind_char J
    bind_char K
    bind_char L
    bind_char N
    bind_char O
    bind_char P d
    bind_char Q
    bind_char R
    bind_char S d
    bind_char T
    bind_char U
    bind_char V d
    bind_char W
    bind_char X d
    bind_char Y
    bind_char Z
    bind_char "Å"
    bind_char "Ä"
    bind_char "Ö"

    header_1 "acute accent"
    bind_char "Á"
    bind_char "É"
    bind_char "Í"
    bind_char "Ó"
    bind_char "Ú"
    bind_char "Ý"
}

non_letter_regular_cars() {

    header_1 "non-letter regular keys"
    bind_char "§"
    bind_char "1"
    bind_char "2"
    bind_char "3"
    bind_char "4"
    bind_char "5"
    bind_char "6"
    bind_char "7"
    bind_char "8"
    bind_char "9"
    bind_char "0"
    bind_char "±" # plus-minus sign
    bind_char "°" # degree symbol
    bind_char "!"
    bind_char "@"
    bind_char "#" s
    bind_char "£"
    bind_char "€"
    bind_char "^"
    bind_char "("
    bind_char ")"
    bind_char "-"
    bind_char "_"
    bind_char "="
    bind_char "´"
    bind_char "+"

    case "$mod" in
    C- | C-M-) tmux_vers_ok 3.5 && bind_char "[" ;;
    *) ;;
    esac

    bind_char "]"
    bind_char "\\\\"
    bind_char ":"
    bind_char "'" d
    bind_char ","
    bind_char "."
    bind_char "<" d
    bind_char ">" d
    bind_char "?" d

    tmux_vers_ok 3.0 && bind_char ";" d

    tmux_vers_ok 3.3 || {
        case "$mod" in
        C- | C-M-) return ;;
        *) ;;
        esac
    }
    bind_char "\`" d
    bind_char "/"

    tmux_vers_ok 3.5 || {
        case "$mod" in
        C- | C-M-) return ;;
        *) ;;
        esac
    }
    bind_char '~' s
    bind_char '$' s
    bind_char % d
    bind_char "\&" d
    bind_char '*' d
    bind_char "{" d
    bind_char "}" d
    bind_char "|" d
    bind_char '"' s
}

special_basic_keys() {
    header_2 "Special basic keys"
    bind_char Tab
    bind_char bTab
    bind_char Enter
    bind_char Space
    bind_char BSpace
    bind_char Up
    bind_char Down
    bind_char Left
    bind_char Right

    tmux_vers_ok 3.3 || {
        case "$mod" in
        C- | C-S- | C-M- | C-M-S-) return ;;
        *) ;;
        esac
    }
    bind_char Escape
}

func_keys() {
    header_2 "Function keys"
    bind_char F1
    bind_char F2
    bind_char F3
    bind_char F4
    bind_char F5
    bind_char F6
    bind_char F7
    bind_char F8
    bind_char F9
    bind_char F10
    bind_char F11
    bind_char F12
}

above_arrows() {
    header_2 "Group normally above arrows"
    bind_char IC # Insert
    bind_char DC # Delete
    bind_char Home
    bind_char End
    bind_char PgUp
    bind_char PgDn
}

num_keyboard() {
    header_2 "Num Keyboard"
    bind_char KP/
    bind_char "KP*" d
    bind_char KP-
    bind_char KP7
    bind_char KP8
    bind_char KP9
    bind_char KP+
    bind_char KP4
    bind_char KP5
    bind_char KP6
    bind_char KP1
    bind_char KP2
    bind_char KP3
    bind_char KPEnter
    bind_char KP0
    bind_char KP.
}

regular_chars() {
    case "$mod" in
    S- | C-S- | M-S- | C-M-S-) return ;;
    *) ;;
    esac

    header_2 "Regular keys"
    lower_case_chars
    upper_case_chars
    non_letter_regular_cars
}

do_keys() {
    # mouse_event_via_script
    mouse_events
    regular_chars
    special_basic_keys
    func_keys
    above_arrows
    num_keyboard
}

process_mod() {
    mod="$1"
    case "$mod" in
    "") mod_long="No Prefix" ;;
    S-) mod_long="Shift" ;;
    C-) mod_long="Control" ;;
    M-) mod_long="Meta" ;;
    C-S-) mod_long="Control-Shift" ;;
    M-S-) mod_long="Meta-Shift" ;;
    C-M-) mod_long="Control-Meta" ;;
    C-M-S-) mod_long="Control-Meta-Shift" ;;
    *) mod_long="Unknown mod: $mod" ;;
    esac

    header_3 "$mod_long"

    do_keys
}

#===============================================================
#
#   Main
#
#===============================================================

d_tkbtst_location="$(dirname "$(realpath "$0")")"

. "$d_tkbtst_location"/utils.sh

tmux_vers_ok 2.4 || {
    echo
    echo "ERROR: This requires tmux >= 2.4!"
    echo
    exit 1
}

rm -f "$tmux_conf"
base_conf
process_mod ""
process_mod "S-"
process_mod "C-"
process_mod "C-S-"
process_mod "M-"
process_mod "M-S-"
process_mod "C-M-"
process_mod "C-M-S-"
