#!/bin/sh

#
#  Insertion date: 2025-01-28
#

#
# To make this safer to include in other code, functions and variables
# believed to be of use outside this are prefixed with tpt_
# all other variables use _ prefix to clearly list them as temporary.
# This should ensure this will not collide with any other namespaces.
#
# Env variables that can be set:
#   tpt_debug_mode - if set to 1 tpt_dependency_check will print progress to /dev/stderr

# Variables defined, that might be useful outside of this:
#   tpt_missing_dependencies - Lists all failed dependencies found
#
# The following will only be set if this was sourced by a script running inside
# a tmux plugin, otherwise unset
#   tpt_d_plugin             - the name of the folder containing the plugin
#   tpt_plugin_name          - the name of the plugin
#

#===============================================================
#
#   Primary functions provided
#
#===============================================================

# Checks if the running tmux version is at least the specified version.
tmux_vers_ok() {
    _v_comp="$1" # Desired minimum version to check against

    # Retrieve and cache the current tmux version on the first call
    if [ -z "$tpt_current_vers" ]; then
        tpt_current_vers="$(tmux -V | cut -d' ' -f2)"
        tpt_current_vers_i="$(tpt_digits_from_string "$tpt_current_vers")"
        tpt_current_vers_suffix="$(tpt_tmux_vers_suffix "$tpt_current_vers")"
    fi

    # Compare numeric parts first for quick decisions.
    _i_comp="$(tpt_digits_from_string "$_v_comp")"
    [ "$_i_comp" -lt "$tpt_current_vers_i" ] && return 0
    [ "$_i_comp" -gt "$tpt_current_vers_i" ] && return 1

    # Compare suffixes only if numeric parts are equal.
    _suf="$(tpt_tmux_vers_suffix "$_v_comp")"
    # - If no suffix is required or suffix matches, return success
    [ -z "$_suf" ] || [ "$_suf" = "$tpt_current_vers_suffix" ] && return 0
    # If the desired version has a suffix but the running version doesn't, fail
    [ -n "$_suf" ] && [ -z "$tpt_current_vers_suffix" ] && return 1
    # Perform lexicographical comparison of suffixes only if necessary
    [ "$(printf '%s\n%s\n' "$_suf" "$tpt_current_vers_suffix" |
        LC_COLLATE=C sort | head -n 1)" = "$_suf" ] && return 0

    # If none of the above conditions are met, the version is insufficient
    return 1
}

tpt_dependency_check() {
    # Function Purpose:
    #  This function checks if all required tools are installed on the system.
    #  If any tools are missing, it displays a notification listing the missing
    #  dependencies and returns false.
    #
    # It is designed to simplify dependency checks, particularly for tmux plugins,
    # and includes version-aware reporting to ensure compatibility with different
    # tmux versions.
    #
    # Key Features:
    # 1. Tool Availability Check:
    #    Each listed tool or alternative (e.g., fzf|sk) is checked using `command -v`.
    #    If a tool isn't available, the function handles the failure gracefully.
    #
    # 2. Version-Specific Notifications:
    #    - For tmux 3.2 or newer, missing dependencies are displayed using
    #      display-popup, which stays open until manually closed. This ensures users
    #      see and address all issues before continuing.
    #    - For older tmux versions, it falls back to display-message, which doesn't
    #      persist as reliably but still informs users of missing dependencies.
    #
    # 3. Better User Awareness:
    #    - By pausing on display-popup, the function ensures all dependency issues
    #      are shown without being overwritten by other plugin notifications.
    #    - This avoids the common issue where multiple plugin messages overlap
    #      or disappear quickly during tmux initialization.
    #
    # Parameters:
    #   $1: A space-separated list of tools to check for.
    #       Use a|b to indicate that either tool `a` OR tool `b` can satisfy the
    #       requirement (e.g., "sqlite3 fzf|sk ruby").
    #
    # Defined Variables:
    #   tpt_missing_dependencies - Holds a list of missing tools if any are found.
    tpt_log_it "dependency_check($1)"

    _dependencies="$1"
    tpt_define_plugin_env
    tpt_d_plugin="$(dirname "$(realpath "$0")")"
    tpt_plugin_name="$(basename "$(dirname "$(realpath "$0")")")"

    [ "$tpt_debug_mode" = "1" ] && tpt_display_env

    if tpt_verify_dependencies "$_dependencies"; then
        tpt_log_it "no missing dependencies!"
        # removing hint file if previously created
    else
        tpt_log_it "missing dependencies FOUND"
        if tpt_tmux_vers_ok 3.2; then
            _failed_dependencies_formatted="$(printf "%s" "$tpt_missing_dependencies" |
                tr ' ' '\n' | sed 's/\|/ or /g')"
            tpt_log_it "_failed_dependencies_formatted: [$_failed_dependencies_formatted]"
            _err_msg="Failed dependencies for plugin: $tpt_plugin_name\n\n"
            _err_msg="${_err_msg}$_failed_dependencies_formatted"
            # Termux doesn't do the default 50% size on smaller screens
            # without it being spelled out
            $TMUX_BIN display-popup -h 50% -w 50% \
                -T " Tmux Dependency issue " printf "$_err_msg"
        else
            _err_msg="DEPENDENCY: plugin $tpt_plugin_name"
            _err_msg="$_err_msg requires: $tpt_missing_dependencies"
            $TMUX_BIN display "$_err_msg"
        fi
        return 1
    fi
    return 0
}

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

# Extracts all numeric digits from a string, ignoring other characters.
# Example inputs and outputs:
#   "tmux 1.9" => "19"
#   "1.9a"     => "19"
tpt_digits_from_string() {
    _i="$(echo "$1" | tr -cd '0-9')" # Use 'tr' to keep only digits
    echo "$_i"
}

# Extracts any alphabetic suffix from the end of a version string.
# If no suffix exists, returns an empty string.
# Example inputs and outputs:
#   "3.2"  => ""
#   "3.2a" => "a"
tpt_tmux_vers_suffix() {
    echo "$1" | sed 's/.*[0-9]\([a-zA-Z]*\)$/\1/'
}

#---------------------------------------------------------------
#
#   Dependency check related support functions
#
#---------------------------------------------------------------

tpt_display_env() {
    tpt_log_it "tpt_d_plugin: $tpt_d_plugin"
    tpt_log_it "tpt_plugin_name: $tpt_plugin_name"
    tpt_log_it "Dependencies: $_dependencies"
}

tpt_log_it() {
    #
    # Internal function to help debugging
    [ "$tpt_debug_mode" = "1" ] && {
        echo "><> $1" >/dev/stderr
    }
}

tpt_add_missing_dependeny() {
    tpt_log_it "      tpt_add_missing_dependeny($1)"
    _s="$tpt_missing_dependencies"
    if [ -z "$tpt_missing_dependencies" ]; then
        tpt_missing_dependencies="$1"
    else
        tpt_missing_dependencies="$tpt_missing_dependencies $1"
    fi
    tpt_log_it "dependencies before[$_s] after[$tpt_missing_dependencies]"
}

tpt_verify_dependencies() {
    #
    #  Returns true if all the dependencies could be found
    # notation: "curl" "fzf|sk"
    #
    tpt_log_it "tpt_verify_dependencies($1)"
    tpt_missing_dependencies=""
    # shellcheck disable=SC2068 # in this case we want to split the param
    for _dep_group in $@; do
        tpt_log_it " dep_group: >$_dep_group<"
        for _dep in $(echo "$_dep_group" | tr "|" ' '); do
            tpt_log_it "  _dep: >$_dep<"
            if command -v "$_dep" >/dev/null 2>&1; then
                continue 2
            fi
        done
        tpt_add_missing_dependeny "$_dep_group"
    done
    # Equivalent to 'return' with a boolean result
    [ -z "$tpt_missing_dependencies" ]
}

tpt_testing() {
    # dependency_check "sqlite3"     # for tmux-packet-loss
    # tst_checker "sk|fzf bash" # for extrakto
    # tst_checker "ruby"        # for tmux-packet-loss

    # #
    # # Test dependencies to see if it works as intended, with multiple bad ones, t
    # # to ensure it accepts the good one reagdless if it is in the beginig middle or
    # # end of the sub options
    # #

    # tst_checker "ls|foo_a|foo_b|foo_c"
    # tst_checker "foo_a|ls|foo_b|foo_c"
    # tst_checker "foo_b|foo_a|ls|foo_c"
    # tst_checker "foo_b|foo_a|foo_c|ls"

    # Will trigge dependency fail
    # dependency_check "ls"
    # dependency_check "foo_a"
    # dependency_check "foo_a foo_b ls"
    tpt_dependency_check "foo_a|foo_b foo_c ls"
}

#===============================================================
#
#   Main
#
#===============================================================
# Only set this if undefined
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"
tpt_debug_mode=0
