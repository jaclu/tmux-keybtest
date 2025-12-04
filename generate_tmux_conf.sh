#!/usr/bin/env bash
#
#   Copyright (c) 2024-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-keybtest
#
#  This will generate a tmux.conf adjusted to the version of tmux being used
#

#---------------------------------------------------------------
#
#  Write to $tmux_conf
#
#---------------------------------------------------------------
writeln() {
    printf "%s\n" "$1" >>"$tmux_conf"
}

bind_char() {
    # second param indicates how char should be wrapped
    # bind_char "1"        bind -n 1 display-message "1"
    # bind_char '"' s      bind -n '"' display-message '"'
    # bind_char "|" d      bind -n "|" display-message "|"
    # bind_char ";" db     bind -n "\;" display-message "\\;"
    local key="$1"
    local handling="$2"
    local output="bind -n "

    [[ -z "$key" ]] && {
        echo "ERROR: call to bind_char() with no param"
        exit 1
    }
    if [[ -n "$skip_message" ]]; then
        output="# ${mod}$key  -  ## $skip_message"
        writeln "$output"
        return
    fi

    if [[ "$no_shift" = 1 ]]; then
        # Indicate this key does not have a shift variant
        case "$mod" in
            S- | C-S- | M-S- | C-M-S-)
                writeln "# ${mod}$key - key-sequence does not exist"
                return
                ;;
            *) ;;
        esac
    fi
    if [[ "$no_ctrl" = 1 ]]; then
        # Indicate this key does not have a ctrl variant
        case "$mod" in
            C- | C-S- | C-M-)
            writeln "# ${mod}$key - key-sequence does not exist"
            return
            ;;
            *) ;;
        esac
    fi
    if [[ "$no_meta" = 1 ]]; then
        # Indicate this key does not have a meta variant
        case "$mod" in
            M- | M-S- | C-M- | C-S-M-)
                writeln "# ${mod}$key - key-sequence does not exist"
                return
                ;;
            *) ;;
        esac
    fi

    case "$handling" in
    s | S)  # single quotes
        output+="'${mod}$key' display-message '${mod}$key'" ;;
    d | D)  # double quotes
        output+="\"${mod}$key\" display-message \"${mod}$key\"" ;;
    db | DB) # double quotes & backslash
        output+="\"${mod}\\$key\" display-message \"${mod}\\\\$key\"" ;;
    *) output+="${mod}$key display-message \"${mod}$key\"" ;;
    esac

    writeln "$output"
}

# # Not used ATM
# bind_mouse_script() {
#     local output="bind -n "

#     [[ -z "$1" ]] && {
#         echo "ERROR: call to bind_run() with no param"
#         exit 1
#     }
#     output+="'${mod}$1' $run_shell_bg '$f_mouse_event ${mod}$1'"
#     writeln "$output"
# }

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

#---------------------------------------------------------------
#
#  Define core tmux environment
#
#---------------------------------------------------------------

base_config() {

    writeln "#==========================================================="
    writeln "#"
    writeln "#  Tmux conf for teting keyboard implementation, and what"
    writeln "#  non standard sequences it can generate. - Arrows with modifiers etc"
    # shellcheck disable=SC2154
    writeln "# Created for tmux version: $tpt_current_vers"
    writeln "#"
    writeln "#==========================================================="
    writeln "#"
    writeln "#  Base config"
    writeln "#"
    writeln "$opt_s prefix C-x"
    writeln "bind C-c kill-server"
    # writeln "set-option -s escape-time 100"
    writeln "$opt_s display-time 1000"
    writeln "$opt_w monitor-activity off"
    writeln "$opt_s visual-bell on"
    # writeln "$opt_s focus-events on"

    $use_mouse && tmux_vers_ok "$mouse_vers_min" && writeln "$opt_s mouse on"
    tmux_vers_ok 2.6 && writeln "$opt_s monitor-bell off"
    tmux_vers_ok 2.8 && writeln "bind Any display 'This key is not bound to any action'"
    tmux_vers_ok 3.2 && {
        writeln "$opt_s extended-keys on"
        writeln "set -g -a terminal-features '*:extkeys'"
    }

    writeln
    writeln "# Handling of unbound keys"
    msg="Keys tmux did not capture will be displayed below "
    if tmux_vers_ok 1.5 && command -v showkey >/dev/null; then
        cmd="showkey -a"
        msg+="using \"showkey -a\""
        writeln "$opt_s default-command 'echo $msg ; echo ; $cmd'"
    else
        # fallback if no showkey
        msg+="without parsing"
        writeln "$opt_s default-command 'echo $msg ; echo ; sleep 36000'"
    fi
}

define_status_bar() {
    local line_1="Displays recognized un-prefixed keys"
    $use_mouse && line_1+=" and mouse events"
    local exit_procedure="To exit press C-x then C-c."

    if tmux_vers_ok 3.0; then
        unlimited=0
    else
        unlimited=999
    fi
    writeln
    writeln "#"
    writeln "#  Status bar configuration"
    writeln "#"
    writeln "$opt_s status-left-length $unlimited"
    writeln "$opt_s status-right-length $unlimited"

    writeln
    if tmux_vers_ok 2.9; then
        #
        # Use line 2 for general info
        #
        writeln "#  Display some hints in status bar left row 2"
        writeln "$opt_s status 2"
        writeln "$opt_s status-format[1] '$exit_procedure'"
        writeln "$opt_s window-status-current-format ''"
        writeln "$opt_s status-left ''" # Clear it to suppress ses name from showing
    else
        #
        # For older version only one line is available
        #
        writeln "# Display exit hint in Status bar left"
        writeln "$opt_s status-justify left"
        if tmux_vers_ok 1.4; then
            writeln "$opt_w window-status-format ''"
            writeln "$opt_w window-status-current-format ''"
        fi
        writeln "$opt_s status-left '$exit_procedure This displays recognized keys'"
    fi

    writeln
    writeln "# Display currently used tmux version & prefix key pressed in Status bar right"
    local prefix_color=" #[fg=colour231]#[bg=colour04]"
    local prefix_pressed="Got C-x - Press ${prefix_color}C-c#[default] to exit"

    local serv_vers_info="tmux version:#[fg=green]#[bg=black] $tpt_current_vers#[default]"
    if tmux_vers_ok 1.8; then
        writeln "$opt_s status-right \"#{?client_prefix,$prefix_pressed,$serv_vers_info}\""
    else
        writeln "$opt_s status-right \"$serv_vers_info\""
    fi
}

setup_tmux_server() {
    opt_s="set-option -g"
    if tmux_vers_ok 1.5; then
        opt_w="set -w -g"
    else
        opt_w="set-window-option -g"
    fi
    # if tmux_vers_ok 1.7; then
    #     run_shell_bg="run-shell -b"
    # else
    #     run_shell_bg="run-shell"
    # fi
    base_config
    define_status_bar
}

#---------------------------------------------------------------
#
#  Display various inputs
#
#---------------------------------------------------------------

mouse_handling() {
    local old_ifs="$IFS"
    local locations=(
        Pane
        Border
        Status
    )
    local mouse_events=(
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
    local event button location

    tmux_vers_ok 2.4 && {
        mouse_events+=(
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
        mouse_events+=(
            SecondClick
        )
    }
    writeln
    writeln
    writeln "#==========================================================="
    writeln "#"
    writeln "#  Mouse handling"
    writeln "#"
    writeln "#==========================================================="
    writeln
    old_ifs="$IFS"
    IFS=$'\n'
    for location in "${locations[@]}"; do
        for event in "${mouse_events[@]}"; do
            for button in "${buttons[@]}"; do
                # bind_mouse_script "${event}${button}${location}"
                bind_char "${event}${button}${location}" s
            done
        done
        # Obly loop over location for Wheel events
        bind_char "WheelUp$location"
        bind_char "WheelDown$location"
    done
    IFS="$old_ifs"
}

lower_case_chars() {
    skip_message=""
    header_3 "Lower Case"

    case "$mod" in
    S- | C-S- | M-S- | C-M-S-)
        writeln "# $mod  - should be handled in Upper Case section"
        return
        ;;
    *) ;;
    esac

    bind_char a
    bind_char b
    bind_char c
    bind_char d
    bind_char e
    bind_char f
    bind_char g
    bind_char h

    case "$mod" in
    C- | C-M-)
        if tmux_vers_ok 3.5; then
            bind_char i
        else
            writeln "# Prior to 3.5 ${mod}i overrides Tab"
        fi
        ;;
    *) bind_char i ;;
    esac

    bind_char j
    bind_char k
    bind_char l

    case "$mod" in
    C- | C-M-)
        if tmux_vers_ok 3.5; then
            bind_char m
        else
            writeln "# Prior to 3.5 ${mod}m overrides Enter"
        fi
        ;;
    *) bind_char m ;;
    esac

    bind_char n
    bind_char o
    bind_char p
    bind_char q
    bind_char r
    bind_char s
    bind_char t
    bind_char u
    bind_char v
    bind_char w

    case "$mod" in
    C-)
        # Special case don't bind this to the root table, in order to display prefix
        # on second press
        writeln "bind '${mod}x' display-message '${mod}x'"
        ;;
    *) bind_char x ;;
    esac

    bind_char y
    bind_char z

    ! tmux_vers_ok 2.2 && {
        skip_message="Accents & umlauts can't be bound before 2.2"
    }
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

upper_case_chars() {
    skip_message=""
    header_3 "Upper Case"
    case "$mod" in
    C- | C-M-)
        if ! tmux_vers_ok 3.2; then
            skip_message="Prior to 3.2 ${mod}Uppercase overrides ${mod}Lowercase"
        elif ! tmux_vers_ok 3.6; then
            #region Blurb about using C-S-A instead of C-A
            writeln "
#
#  Versions 3.2 - 3.5 didn't handle ${mod}Uppercase properly.
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
    C-S- | C-M-S-)
        if ! tmux_vers_ok 3.2 || ! tmux_vers_ok 3.6; then
            skip_message="${mod}Uppercase only meaningful 3.2 - 3.5"
        fi
        ;;
    S- | M-S-) skip_message="S- modifier pointless" ;;
    *) ;;
    esac

    bind_char A
    bind_char B
    bind_char C
    bind_char D
    bind_char E
    bind_char F
    bind_char G
    bind_char H

    case "$mod" in
    C- | C-M-)
        if tmux_vers_ok 3.5; then
            bind_char I
        else
            writeln "# Prior to 3.5 ${mod}I overrides Tab"
        fi
        ;;
    *) bind_char I ;;
    esac

    bind_char J
    bind_char K
    bind_char L

    case "$mod" in
    C- | C-M-)
        if tmux_vers_ok 3.5; then
            bind_char M
        else
            writeln "# Prior to 3.5 ${mod}M overrides Enter"
        fi
        ;;
    *) bind_char M ;;
    esac

    bind_char N
    bind_char O
    bind_char P
    bind_char Q
    bind_char R
    bind_char S
    bind_char T
    bind_char U
    bind_char V
    bind_char W
    bind_char X
    bind_char Y
    bind_char Z

    [[ -z "$skip_message" ]] && ! tmux_vers_ok 2.2 && {
        skip_message="Accents & umlauts can't be bound before 2.2"
    }
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
}

non_letter_regular_cars() {
    skip_message=""
    header_3 "non-letter regular keys"

    case "$mod" in
    S- | C-S- | M-S- | C-M-S-)
        writeln "# $mod  - These don't differ between upper/lower case"
        return
        ;;
    *) ;;
    esac


    bind_char "@"
    bind_char "^"
    bind_char "_"

    case "$mod" in
    C- | C-M-)
        if tmux_vers_ok 3.5; then
            bind_char "["
        else
            writeln "# Prior to 3.5 ${mod}[ overrides Escape"
        fi
        ;;
    *) bind_char "[" ;;
    esac

    bind_char "]"
    bind_char "\\\\" d

    #
    # Sorted
    #
    (
        local no_ctrl=1

        bind_char "!"
        bind_char '"' s
        bind_char '#' s
        bind_char '$' s
        bind_char % d
        bind_char "\&" d
        bind_char "'" d
        bind_char "("
        bind_char ")"
        bind_char '*' d
        bind_char "+"
        bind_char ","
        bind_char "-"
        bind_char "."
        bind_char "/"
        bind_char "0"
        bind_char "1"
        bind_char "2"
        bind_char "3"
        bind_char "4"
        bind_char "5"
        bind_char "6"
        bind_char "7"
        bind_char "8"
        bind_char "9"
        bind_char ":"
        bind_char "<" d
        bind_char "="
        bind_char ">" d
        bind_char "?" d
        bind_char "\`" d
        bind_char "{" d
        bind_char "|" d
        bind_char "}" d
        bind_char '~' s

        ! tmux_vers_ok 3.0 && skip_message="Not handled before 3.0"
        bind_char ";" db

        ! tmux_vers_ok 2.2 && skip_message="Not handled before 2.2"
        bind_char §
        bind_char ± # plus-minus sign
        bind_char ° # degree symbol
        bind_char £
        bind_char €
        bind_char "´"
    )
}

special_basic_keys() {
    skip_message=""
    header_2 "Special basic keys"

    case "$mod" in
        C- | C-S- | C-M- | C-M-S-)
            if tmux_vers_ok 1.7; then
                bind_char Tab
            fi
            ;;
        S-)
            if tmux_vers_ok 1.4; then
                bind_char Tab
            fi
            ;;
        *) bind_char Tab ;;
    esac

    bind_char bTab

    # case "$mod" in
    #     C- | C-S- | C-M- | C-M-S-)
    #         if tmux_vers_ok 1.7; then
    #             bind_char Enter
    #         fi
    #         ;;
    #     *) bind_char Enter ;;
    # esac
    (
        local no_shift=1
        bind_char Space

        local no_ctrl=1
        bind_char Enter
    )
    bind_char BSpace
    bind_char Up
    bind_char Down
    bind_char Left
    bind_char Right

    case "$mod" in
        M- | M-S- | C-M- | C-M-S-) tmux_vers_ok 2.3 || skip_message="Not handled before 2.3" ;;
        *) ;;
    esac
    local no_shift=1
    local no_ctrl=1
    bind_char Escape
}

func_keys() {
    skip_message=""
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
    skip_message=""
    header_2 "Group normally above arrows"
    bind_char IC # Insert
    bind_char DC # Delete
    bind_char Home
    bind_char End
    if tmux_vers_ok 1.6; then
        bind_char PgUp
        bind_char PgDn
    else
        bind_char PPage
        bind_char NPage
    fi
}

num_keyboard() {
    skip_message=""
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
    lower_case_chars
    upper_case_chars
    non_letter_regular_cars
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

    echo "Configuring key capture for modifier: $mod_long" >/dev/stderr

    header_1 "$mod_long"
    regular_chars
    special_basic_keys
    func_keys
    above_arrows
    num_keyboard
    $use_mouse && tmux_vers_ok "$mouse_vers_min" && mouse_handling
}

#===============================================================
#
#   Main
#
#===============================================================

d_tkbtst_location="$(dirname "$(realpath "$0")")"

# If either is 1 the modifier does not have any valid key sequences
no_shift=0
no_ctrl=0
no_meta=0

skip_message=""

use_mouse=false
mouse_vers_min="2.1"

# shellcheck source=utils.sh
. "$d_tkbtst_location"/utils.sh

[[ "$1" = "-m" ]] && {
    tmux_vers_ok "$mouse_vers_min" || {
        echo "ERROR: mouse can't be used in this app prior to tmux $mouse_vers_min"
        exit 1
    }
    use_mouse=true
}

rm -f "$tmux_conf"
tpt_retrieve_running_tmux_vers

setup_tmux_server
process_mod ""
process_mod "S-"
process_mod "C-"
process_mod "C-S-"
process_mod "M-"
process_mod "M-S-"
process_mod "C-M-"
process_mod "C-M-S-"

exit 0
