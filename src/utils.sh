#!/bin/bash

if [[ $UTILS_SH ]]; then return; fi
UTILS_SH=true

# set globbing options
shopt -s extglob
shopt -s nullglob

# define valid service actions
# respective .sh files must exist in service dirs
SERVICE_ACTIONS=( run start stop )

# define all valid commands
COMMANDS=( ls )
COMMANDS+=( "${SERVICE_ACTIONS[@]}" )

# format SERVICE_ACTIONS and COMMANDS as string, separated by |
old_ifs="$IFS"
IFS='|'
SERVICE_ACTIONS_STR="${SERVICE_ACTIONS[*]}"
COMMANDS_STR="${COMMANDS[*]}"
IFS="$old_ifs"


# returns 0 if $1 is contained in array ($2 $3 ...)
# e.g.:
#    array=( 1 2 3 )
#    element_in 2 "${array[@]}"
# returns 0
element_in() {
    local elem match="$1"
    shift
    for elem in "$@"; do [[ $elem == $match ]] && return 0; done
    return 1
}
