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
SERVICE_ACTIONS=( 'start' 'stop' 'backup' )

# define all valid commands
COMMANDS=( 'ls' )
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

# copy value of $1 to $2
#cp_var() {
#    local cmd="$(declare -p "$1" 2>/dev/null)"
#    local pattern="^declare -([[:alpha:]-]*) $1=(.*)"
#    [[ $cmd =~ $pattern ]]
#    unset "$2"
#    eval "declare -${BASH_REMATCH[1]//[r-]}g $2=${BASH_REMATCH[2]}"
#    declare -n var=$2
#    eval "declare -${BASH_REMATCH[1]//[r-]}g $2=${BASH_REMATCH[2]}"
#
#}

# RULES
# a function's return value is stored in the global variable "retval"
# to copy a variable, use 'declare -* newvar="$(get_declare oldvar)"', where * stands for arbitrary declare options
# to set $retval in a function, use 'unset retval; declare -*g retval=...'

# TODO: check out https://stackoverflow.com/a/8881121


get_declare() {
    local cmd="$(declare -p "$1" 2>/dev/null)"
    local pattern="^declare -([[:alpha:]-]*) $1=(.*)"
    [[ $cmd =~ $pattern ]]
    echo "${BASH_REMATCH[2]}"
}

get_dec() {
    get_declare "$@"
}


# $1,$2,..: dicts as declare-strings
merge_dicts() {
    unset retval
    declare -A merged_dict

    for dict_str in "$@"; do
        declare -A dict="$dict_str"
        for key in "${!dict[@]}"; do
            merged_dict["$key"]="${dict[$key]}"
        done
    done

    declare -Ag retval=$(get_dec merged_dict)
}



# run command $1 with arguments $2 $3 ..., but indent output
# keeps stdout and stderr
#indent() {
#    cmd="$1"; shift
#    "$cmd" "$@" \
#        > >(sed "s/^/    /g") \
#        2> >(sed "s/^/    /g" >&2)
#}
#!/bin/bash


# $1: service
get_service_status() {
    unset retval
    retval=$(execute_action "get_status" "$1")
}
