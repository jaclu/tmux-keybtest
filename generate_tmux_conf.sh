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
    writeln
    writeln "#==========================================================="
    writeln "#"
    writeln "#  Segment covering modifier: $1"
    writeln "#"
    writeln "#==========================================================="
}

header_2() {
    writeln
    writeln "#"
    writeln "#  $1"
    writeln "#"
}

header_3() {
    writeln
    writeln "#  --  $1"
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

bind_mouse_event() {
    local output="bind -n "

    [[ -z "$1" ]] && {
        echo "ERROR: call to bind_run() with no param"
        exit 1
    }
    output+="'${mod}$1' run-shell -b '$f_mouse_event ${mod}$1'"
    writeln "$output"

}

base_conf() {
    #region base config
    # shellcheck disable=SC2154
    writeln "#===========================================================
#
#  Tmux conf for teting keyboard implementation, and what
#  non standard sequences it can generate. - Arrows with modifiers etc
# Created for tmux version: $tpt_current_vers
#   int:    $tpt_current_vers_i
#   suffix: $tpt_current_vers_suffix
#
#===========================================================

#
#  Base config
#
set-option -g prefix C-x
bind C-c kill-server
set-option -s escape-time 100
set-option -g display-time 1000
set-option -g monitor-activity off
set-option -g visual-bell on
set-option -g focus-events on"
    #endregion
    tmux_vers_ok 2.4 && writeln "set-option -g monitor-bell off"
    tmux_vers_ok 2.1 && writeln "set-option -g mouse on"
    tmux_vers_ok 2.8 && writeln "bind Any display 'This key is not bound to any action'"
    tmux_vers_ok 3.2 && writeln "set-option -g extended-keys on"

    #region Display current tmux vers in Status bar left
    writeln "
#
# Display currently used tmux version in Status bar left
#
set-option -g status-left-length 20
set-option -g status-left 'tmux version:#[fg=white,bg=black]$tpt_current_vers#[default] '
"
    #endregion

    #region Display prefix key pressed in Status bar right
    writeln "
#
# Display prefix key pressed in Status bar right
#
set-option -g status-right-length 0
set-option -g status-right '#{?client_prefix,Prefix #[fg=colour231]#[bg=colour04]C-x#[default] - Press C-c to exit,}'
# run-shell -b 'sleep 0.5 ; tmux send-keys \"showkey -a\" C-M'
set-option -g default-command '/bin/sh'
"
    #endregion

    tmux_vers_ok 2.9 && {
        _line_1="Displays keys and mouse events recognized by tmux in status-bar"
        #region Display some hints in status bar left row 2 & 3
        writeln "
#
#  Display some hints in status bar left row 2 & 3
#
set-option -g status 3
set-option -g status-format[1] '$_line_1'
set-option -g status-format[2] 'To exit press C-x then C-c. To test C-x press it twice'"
        #endregion
    }

    #     tmux_vers_ok 3.0 && {
    #         #region unbind default popup menus
    #         writeln "
    # #======================================================
    # #
    # #   Remove unwanted default popup menus
    # #
    # #======================================================
    # unbind  -n  MouseDown3Pane
    # unbind  -n  MouseDown3Status
    # unbind  -n  MouseDown3StatusLeft
    # unbind  -n  M-MouseDown3Pane"
    #         #endregion
    #     }
    #     ! tmux_vers_ok 3.1 && writeln "unbind  -n  MouseDown3StatusRight"
    #     tmux_vers_ok "3.0a" && {
    #         writeln "unbind  <"
    #         writeln "unbind  >"
    #     }
    #     tmux_vers_ok 3.4 && {
    #         writeln "unbind  -n  M-MouseDown3Status"
    #         writeln "unbind  -n  M-MouseDown3StatusLeft"
    #     }
}

mouse_event_via_script() {
    # Doesn't work right now, using mouse_events() instead

    header_2 "Mouse via script"
    bind_mouse_event WheelUpPane
    bind_mouse_event WheelDownPane
    bind_mouse_event MouseDown1Pane
    bind_mouse_event MouseUp1Pane
    bind_mouse_event MouseDrag1Pane
    bind_mouse_event MouseDragEnd1Pane
    bind_mouse_event MouseDown2Pan
    bind_mouse_event MouseUp2Pane
    bind_mouse_event MouseDrag2Pane
    bind_mouse_event MouseDragEnd2Pane
    bind_mouse_event MouseDown3Pane
    bind_mouse_event MouseUp3Pane
    bind_mouse_event MouseDrag3Pane
    bind_mouse_event MouseDragEnd3Pane
    bind_mouse_event SecondClick1Pane
    bind_mouse_event SecondClick2Pane
    bind_mouse_event SecondClick3Pane
    bind_mouse_event DoubleClick1Pane
    bind_mouse_event DoubleClick2Pane
    bind_mouse_event DoubleClick3Pane
    bind_mouse_event TripleClick1Pane
    bind_mouse_event TripleClick2Pane
    bind_mouse_event TripleClick3Pane
}

mouse_event_loop() {
    local old_ifs="$IFS"
    local events_123=(
        MouseDown
        MouseUp
        MouseDrag
        MouseDragEnd
    )
    local buttons=(
        1
        2
        3
    )
    local locations=(
        Pane
        Border
        Status
    )
    local event button location

    tmux_vers_ok 3.2 && {
        events_123+=(
            SecondClick
        )
    }
    tmux_vers_ok 2.4 && {
        events_123+=(
            DoubleClick
            TripleClick
        )
    }
    tmux_vers_ok 2.9 && {
        locations+=(
            StatusLeft
            StatusRight
            StatusDefault
        )
    }

    tmux_vers_ok 3.2 && {
        events_123+=(
            SecondClick
        )
    }
    old_ifs="$IFS"
    IFS=$'\n'
    for event in "${events_123[@]}"; do
        for button in "${buttons[@]}"; do
            for location in "${locations[@]}"; do
                # bind_mouse_event "${event}${button}${location}"
                bind_char "${event}${button}${location}" d
            done
        done
    done

    IFS="$old_ifs"
}

# mouse_events_new() {
#     # mouse suffixes
#     mouse_wheel="WheelUp WheelDown"
#     # for all mouse events
#     location_suffixes="Border/Status/StatusLeft/StatusRight"

#     # old_ifs=""$IFS""
#     # IFS=""$separator""

#     # for item in $items; do
#     #     [[ -z ""$item"" ]] && continue
#     #     log_it " item: "$item""
#     #     case ""$item"" in
#     #     */*) loop_over_sub_items ""$item"" ;;
#     #     *)
#     #         is_it_available ""$item"" || add_missing_dependeny ""$item""
#     #         ;;
#     #     esac
#     # done

#     # IFS=""$old_ifs""
# }

# mouse_events() {
#     header_2 "Mouse"
#     #region Mouse
#     bind_char WheelUpPane d
#     bind_char WheelDownPane d
#     bind_char MouseDown1Pane d
#     bind_char MouseUp1Pane d
#     bind_char MouseDrag1Pane d
#     bind_char MouseDragEnd1Pane d
#     bind_char MouseDown2Pane d
#     bind_char MouseUp2Pane d
#     bind_char MouseDrag2Pane d
#     bind_char MouseDragEnd2Pane d
#     bind_char MouseDown3Pane d
#     bind_char MouseUp3Pane d
#     bind_char MouseDrag3Pane d
#     bind_char MouseDragEnd3Pane d
#     bind_char DoubleClick1Pane d
#     bind_char DoubleClick2Pane d
#     bind_char DoubleClick3Pane d
#     bind_char TripleClick1Pane d
#     bind_char TripleClick2Pane d
#     bind_char TripleClick3Pane d

#     tmux_vers_ok 3.2 || return

#     bind_char SecondClick1Pane d
#     bind_char SecondClick2Pane d
#     bind_char SecondClick3Pane d
# }

lower_case_chars() {

    case "$mod" in
    S- | C-S- | M-S- | C-M-S-)
        if ! tmux_vers_ok 3.5; then
            writeln
            writeln "# Prior to 3.5 C- C-M- i & m overrides tab and Enter"
            writeln
            return
        fi
        ;;
    *) ;;
    esac
    header_3 "Lower Case"
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
        if tmux_vers_ok 3.5; then
            writeln
            writeln "# Grouped, since they are handled by the same special case"
            bind_char i
            bind_char m
            writeln
        else
            writeln
            writeln "# Prior to 3.5 C- C-M- i & m overrides tab and Enter"
            writeln
        fi
        ;;
    *)
        writeln
        writeln "# Grouped, since they are handled by the same special case"
        bind_char i
        bind_char m
        writeln
        ;;
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
        # Special case dont bind this to the root table, in order to display prefix
        # on second press
        writeln "bind '${mod}x' display-message '${mod}x'"
        ;;
    *) bind_char x ;;
    esac

    bind_char y
    bind_char z
    tmux_vers_ok 2.2 && {
        bind_char å
        bind_char ä
        bind_char ö

        header_3 "acute accent"
        bind_char á
        bind_char é
        bind_char í
        bind_char ó
        bind_char ú
        bind_char ý
    }
}

upper_case_chars() {

    case "$mod" in
    C- | C-M-)
        if ! tmux_vers_ok 3.2; then
            writeln
            writeln "# Prior to 3.2 Uppercase Ctrl is ignored by tmux"
            writeln
            return
        elif ! tmux_vers_ok 3.5a; then
            #region Blurb about using C-S-A instead of C-A
            writeln "
#
#  Pior to 3.5a tmux didn't handle C-uppercase properly.
#  I will use a/A to make the samples easier to write but is the same for all uppercases.
#
#  Any action bound to C-A will be associated with C-a, overwriting anything already
#  bound to C-a. C-A is not recognized as input by tmux.
#
#  What intuitively would be thought of as C-A does not exist in tmux at this time.
#  It has to be referred to as C-S-a, C-S-A, S-C-a or S-C-A
#
#  Same if you add M- as an additional prefix.
#
#  thus C- / C-M- Uppercase is skipped for this tmux version.
#
"
            #endregion
            return
        fi
        ;;
    *) ;;
    esac

    header_3 "Upper Case"
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
        if tmux_vers_ok 3.5; then
            bind_char I
            bind_char M
        else
            writeln
            writeln "# Prior to 3.5 C- C-M- I & M overrides tab and Enter"
            writeln '~ $ % & * { } | " '
            writeln
        fi
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
    bind_char X
    bind_char Y
    bind_char Z
    if tmux_vers_ok 2.2; then
        bind_char Å
        bind_char Ä
        bind_char Ö

        header_3 "acute accent"
        bind_char Á
        bind_char É
        bind_char Í
        bind_char Ó
        bind_char Ú
        bind_char Ý
    else
        writeln
        writeln "# Prior to 2.2 Umlaut & accented characters can't be bound"
        writeln "# Such as: Å Ä Ö Á É Ý ..."
        writeln
    fi
}

non_letter_regular_cars() {

    header_3 "non-letter regular keys"
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
    tmux_vers_ok 2.2 && {
        bind_char §
        bind_char ± # plus-minus sign
        bind_char ° # degree symbol
        bind_char £
        bind_char €
        bind_char "´"
    }
    bind_char "!"
    bind_char "@"
    bind_char '#' s
    bind_char "^"
    bind_char "("
    bind_char ")"
    bind_char "-"
    bind_char "_"
    bind_char "="
    bind_char "+"

    case "$mod" in
    C- | C-M-)
        if tmux_vers_ok 3.5; then
            bind_char "["
        else
            writeln
            writeln "# Prior to 3.5 [ can not be bound with C- C-M- would override Escape"
            writeln
        fi
        ;;
    *) bind_char "[" ;;
    esac

    bind_char "]"
    bind_char "\\\\" d
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
        "C-" | "C-M-") return ;;
        *) ;;
        esac
    }
    bind_char "\`" d
    bind_char "/"

    tmux_vers_ok 3.5 || {
        case "$mod" in
        C- | C-M-)
            writeln
            writeln "# Prior to 3.5 theese are not possible to bind with C- C-M-:"
            writeln '~ $ % & * { } | " '
            writeln
            return
            ;;
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
        C- | C-S- | C-M- | C-M-S-)
            writeln
            writeln "# Prior to 3.3 it is not possible to bind Escape with C- C-S- C-M- C-M-S-:"
            writeln
            return
            ;;
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
    header_2 "Regular keys"
    case "$mod" in
    S-)
        writeln
        writeln "# It is not meaningfull to bind loswercase with S-"
        writeln
        return
        ;; # none in this group can be bound to S-
    C-S- | ˚¡M-S- | C-M-S-) ;;
    *)
        lower_case_chars
        non_letter_regular_cars
        ;;
    esac

    upper_case_chars
}

do_keys() {
    # tmux_vers_ok 2.1 && {
    #     mouse_event_loop
    #     # mouse_event_via_script
    #     # mouse_events
    #     :
    # }
    regular_chars
    # special_basic_keys
    # func_keys
    # above_arrows
    # num_keyboard
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

    header_1 "$mod_long"

    do_keys
}

#===============================================================
#
#   Main
#
#===============================================================

d_tkbtst_location="$(dirname "$(realpath "$0")")"

# shellcheck source=utils.sh
. "$d_tkbtst_location"/utils.sh

# tmux_vers_ok 2.4 || {
#     echo
#     echo "ERROR: This requires tmux >= 2.4!"
#     echo
#     exit 1
# }

rm -f "$tmux_conf"
tpt_retrieve_running_tmux_vers

base_conf
process_mod ""
process_mod "S-"
process_mod "C-"
process_mod "C-S-"
process_mod "M-"
process_mod "M-S-"
process_mod "C-M-"
process_mod "C-M-S-"
