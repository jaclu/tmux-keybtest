#!/bin/sh

vers_check() {
    v_test="$1"
    if tmux_vers_ok "$v_test"; then
        printf '%s\ton %s\t- is ok\n' "$v_test" "$tpt_current_vers"
    else
        printf '%s\ton %s\t- FAIL\n' "$v_test" "$tpt_current_vers"
    fi
}

dep_check() {
    dependency="$1"
    tpt_dependency_check "$dependency" && echo "Dependencies verified: $dependency"
}

test_versions() {
    echo "Display resulut for tmux_vers_ok vs current tmux - $tpt_current_vers"
    vers_check 3.6a
    vers_check 3.6
    vers_check 3.5c
    vers_check 3.5b
    vers_check 3.5a
    vers_check 3.5
    vers_check 3.4
    vers_check 3.3a
    vers_check 3.3
    vers_check 3.2a
    vers_check 3.2
    vers_check 3.1c
    vers_check 3.1b
    vers_check 3.1a
    vers_check 3.1
    vers_check 3.0a
    vers_check 3.0
    vers_check 2.9a
    vers_check 2.9
    vers_check 2.8
    vers_check 2.7
    vers_check 2.6
    vers_check 2.5
    vers_check 2.4
    vers_check 2.3
    vers_check 2.2
    vers_check 2.1
    vers_check 2.0
}

test_dependencies() {
    dep_check "bash zsh fzf|sk"
}

this_location="$(dirname "$(realpath "$0")")"

# shellcheck source=tmux-plugin-tools.sh
. "$this_location"/tmux-plugin-tools.sh

tpt_define_plugin_env
tpt_retrieve_running_tmux_vers

# shellcheck disable=SC2154
echo "plugin folder detected: $tpt_d_plugin"
# shellcheck disable=SC2154
echo "plugin name detected: $tpt_plugin_name"
echo
test_versions
echo
test_dependencies
