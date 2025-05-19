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
    local output="bind -n "

    [[ -z "$1" ]] && {
        echo "ERROR: call to bind_char() with no param"
        exit 1
    }
    if [[ -n "$skip_message" ]]; then
        output="# ${mod}$1  -  ## $skip_message"
    else
        case "$2" in
        s | S) output+="'${mod}$1' display-message '${mod}$1'" ;;
        d | D) output+="\"${mod}$1\" display-message \"${mod}$1\"" ;;
        *) output+="${mod}$1 display-message \"${mod}$1\"" ;;
        esac
    fi
    writeln "$output"
}

# # Not used ATM
# bind_mouse_script() {
#     local output="bind -n "

#     [[ -z "$1" ]] && {
#         echo "ERROR: call to bind_run() with no param"
#         exit 1
#     }
#     output+="'${mod}$1' run-shell -b '$f_mouse_event ${mod}$1'"
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
#  Handle stack of override messages
#
#---------------------------------------------------------------
push_skip_message() {
    local msg="$1"
    # writeln "# ><> push_skip_message($msg)"
    skip_message_stack+=("$msg") # Push onto stack
    skip_message="$msg"          # Set skip_message
}

pop_skip_message() {
    local len=${#skip_message_stack[@]}

    # [[ "$len" -gt 0 ]] && {
    #     writeln "# ><> pop_skip_message() pre-size: $len msgs: ${skip_message_stack[*]}"
    # }
    if [[ "$len" -gt 0 ]]; then
        unset "skip_message_stack[$((len - 1))]"        # Remove last element
        skip_message_stack=("${skip_message_stack[@]}") # Rebuild array to avoid gaps
    fi

    # Reset skip_message only once using array length check
    if [[ "${#skip_message_stack[@]}" -gt 0 ]]; then
        skip_message="${skip_message_stack[$((${#skip_message_stack[@]} - 1))]}"
        # writeln "# ><> pop_skip_message() post skip_message: $skip_message"
    else
        skip_message="" # If stack is empty, reset skip_message
    fi
}

clear_skip_mesages_stack() {
    # local len=${#skip_message_stack[@]}
    # local msg
    # [[ "$len" -gt 0 ]] && {
    #     msg="# ><> clear_skip_mesages_stack()"
    #     msg+=" pre-size: $len msgs: ${skip_message_stack[*]}"
    #     writeln "$msg"
    # }
    skip_message_stack=() # Clear the stack
    skip_message=""       # Reset skip_message to empty
}

#---------------------------------------------------------------
#
#  Define core tmux environment
#
#---------------------------------------------------------------

base_config() {
    if tmux_vers_ok 3.0; then
        unlimited=0
    else
        unlimited=999
    fi

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
    writeln "set-option -g prefix C-x"
    writeln "bind C-c kill-server"
    writeln "# set-option -s escape-time 100"
    writeln "set-option -g display-time 1000"
    writeln "set-option -g monitor-activity off"
    writeln "set-option -g visual-bell on"
    # writeln "set-option -g focus-events on"
    # to hopefully avoid filling the screen with a fancy prompt, use a minimal shell
    writeln "set-option -g default-command '/bin/sh'"

    $use_mouse && tmux_vers_ok "$mouse_vers_min" && writeln "set-option -g mouse on"
    tmux_vers_ok 2.6 && writeln "set-option -g monitor-bell off"
    tmux_vers_ok 2.8 && writeln "bind Any display 'This key is not bound to any action'"
    tmux_vers_ok 3.2 && {
        writeln "set-option -g extended-keys on"
        writeln "set -g -a terminal-features '*:extkeys'"
    }
    if command -v showkey >/dev/null; then
        cmd="showkey -a" # this is used to display keys tmux did not capure"
    else
        cmd="cat"
    fi
    keys="'$cmd # this is used to display keys tmux did not capure'"
    writeln "run-shell -b \"sleep 0.1 ; tmux send-keys $keys C-M\""
}

define_status_bar() {
    local prefix_color=" #[fg=colour231]#[bg=colour04]"
    # local prefix_pressed="Prefix ${prefix_color}C-x#[default] - Press C-c to exit"
    local prefix_pressed="Got C-x - Next Press ${prefix_color}C-c#[default] to exit"
    local exit_procedure="To exit press C-x then C-c."
    local serv_vers_info="tmux version:#[fg=green,bg=black] $tpt_current_vers #[default]"
    local line_1="Displays recognized un-prefixed keys"

    $use_mouse && line_1+=" and mouse events"
    if tmux_vers_ok 2.9; then
        #
        # Use line 2 & 3 for general info
        #

        writeln
        writeln "#"
        writeln "#  Display some hints in status bar left row 2 & 3"
        writeln "#"
        writeln "set-option -g status 3"
        writeln "set-option -g status-format[1] '$line_1'"
        writeln "set-option -g status-format[2] '$exit_procedure'"
        writeln "set-option -g status-left-length $unlimited"
        writeln "# set-option -g window-status-format ''"
        writeln "set-option -g window-status-current-format ''"
        writeln "set-option -g status-left ''" # Clear it to suppress ses name from showing
    else
        #
        # For older version only one line is available
        #
        writeln
        writeln "#"
        writeln "# Display exit hint in Status bar left"
        writeln "#"
        writeln "set-option -g status-justify left"
        writeln "set-option -g status-left-length $unlimited"
        writeln "set-option -g window-status-format ''"
        writeln "set-option -g window-status-current-format ''"
        writeln "set-option -g status-left '$exit_procedure This displays recognized keys'"
    fi

    writeln
    writeln "#"
    writeln "# Display currently used tmux version & prefix key pressed in Status bar right"
    writeln "#"
    writeln "set-option -g status-right '#{?client_prefix,$prefix_pressed,$serv_vers_info}'"
}

setup_tmux_server() {
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
    clear_skip_mesages_stack
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

    ! tmux_vers_ok 2.2 && push_skip_message "Accents & umlauts can't be bound before 2.2"
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
    clear_skip_mesages_stack
    header_3 "Upper Case"
    case "$mod" in
    C- | C-M-)
        if ! tmux_vers_ok 3.2; then
            push_skip_message "Prior to 3.2 ${mod}Uppercase overrides ${mod}Lowercase"
        elif ! tmux_vers_ok 3.5a; then
            #region Blurb about using C-S-A instead of C-A
            writeln "
#
#  Versions 3.2 - 3.5 didn't handle C-uppercase properly.
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
        if ! tmux_vers_ok 3.2 || tmux_vers_ok 3.5a; then
            push_skip_message "${mod}Uppercase only meaningful 3.2 - 3.5"
        fi
        ;;
    S- | M-S-) push_skip_message "S- modifier pointless" ;;
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
        push_skip_message "Accents & umlauts can't be bound before 2.2"
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
    clear_skip_mesages_stack
    header_3 "non-letter regular keys"

    case "$mod" in
    S- | C-S- | M-S- | C-M-S-)
        writeln "# $mod  - These don't differ between upper/lower case"
        return
        ;;
    *) ;;
    esac

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
            writeln "# Prior to 3.5 ${mod}[ overrides Escape"
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

    if tmux_vers_ok 3.0; then
        bind_char ";" d
    else
        writeln "# Prior to 3.0 ${mod}; not supported"
    fi

    ! tmux_vers_ok 2.2 && push_skip_message "Not handled before 2.2"
    bind_char §
    bind_char ± # plus-minus sign
    bind_char ° # degree symbol
    bind_char £
    bind_char €
    bind_char "´"
    pop_skip_message

    tmux_vers_ok 3.3 || {
        case "$mod" in
        "C-" | "C-M-") push_skip_message "Not handled before 3.3" ;;
        *) ;;
        esac
    }
    bind_char "\`" d
    bind_char "/"

    tmux_vers_ok 3.5 || {
        case "$mod" in
        C- | C-M-) push_skip_message "Not handled before 3.5" ;;
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
    clear_skip_mesages_stack
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

    # tmux_vers_ok 3.1 || {
    #     case "$mod" in
    #     C- | C-S- | C-M- | C-M-S-)
    #         push_skip_message "Not handled before 3.2"
    #         ;;
    #     *) ;;
    #     esac
    # }

    case "$mod" in
    C- | C-S- | C-M- | C-M-S-)
        tmux_vers_ok 3.2a || {
            push_skip_message "Not handled before 3.2a"
        }
        ;;
    *) ;;
    esac
    bind_char Escape
}

func_keys() {
    clear_skip_mesages_stack
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
    clear_skip_mesages_stack
    header_2 "Group normally above arrows"
    bind_char IC # Insert
    bind_char DC # Delete
    bind_char Home
    bind_char End
    bind_char PgUp
    bind_char PgDn
}

num_keyboard() {
    clear_skip_mesages_stack
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

# Stack to store messages
declare -a skip_message_stack=()
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
