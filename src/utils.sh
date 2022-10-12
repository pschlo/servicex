#!/bin/bash

if [[ $UTILS_SH ]]; then return; fi
UTILS_SH=true

# set globbing options
shopt -s extglob
shopt -s nullglob

# WARN: programs in pipe might receive SIGPIPE and exit with 141, thus changing the pipe exit code
set -o pipefail

# define valid service actions
# respective .sh files must exist in service dirs
SERVICE_ACTIONS=( run start stop backup )

# define all valid commands
COMMANDS=( ls )
COMMANDS+=( "${SERVICE_ACTIONS[@]}" )

# format SERVICE_ACTIONS and COMMANDS as string, separated by |
# execute in function so that IFS is only changed there
set_strs() {
    local IFS='|'
    SERVICE_ACTIONS_STR="${SERVICE_ACTIONS[*]}"
    COMMANDS_STR="${COMMANDS[*]}"
}
set_strs


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


# returns host mount point of a named docker volume
get_mount() {
    docker volume inspect --format '{{ .Mountpoint }}' "$1"
}


# see https://stackoverflow.com/a/5431932
container_exists() {
    [[ $(docker ps -a --filter name="$1" | tail -n +2) ]]
}


indent() {
    sed "s/^/    /g"
}

# remove all whitespaces
rem_space() {
    tr -d '[:space:]'
}

rem_single_quote() {
    tr -d "'"
}

trim() {
    sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

contains_space() {
    [[ $1 == *" "* ]]
}

# run command $1 with arguments $2 $3 ..., but indent output
# keeps stdout and stderr
#indent() {
#    cmd="$1"; shift
#    "$cmd" "$@" \
#        > >(sed "s/^/    /g") \
#        2> >(sed "s/^/    /g" >&2)
#}
