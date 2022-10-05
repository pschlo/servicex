#!/bin/bash

# location of script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# enable extended globbing
shopt -s extglob

# define valid service actions
# respective .sh files must exist in service dirs
SERVICE_ACTIONS=( run start stop )

# define all valid commands
COMMANDS=( ls )
COMMANDS+=( "${SERVICE_ACTIONS[@]}" )

# format SERVICE_ACTIONS and COMMANDS as string, separated by |
old_ifs="$IFS"
IFS='|'
SERVICE_ACTIONS_STR=${SERVICE_ACTIONS[*]}
COMMANDS_STR=${COMMANDS[*]}
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


# 1: script/action to run
# 2,3,...: services
dockerex() {
    command="${1,,}"  # ignore case
    shift
    set -- "$command" "$@"  # update positional args

    # using variable in case pattern; see https://stackoverflow.com/q/13254425
    case "$command" in
        ls )
            dockerex-ls "$@" ;;
        @($SERVICE_ACTIONS_STR) )
            dockerex-action "$@" ;;
        * )
            echo "Invalid command."
            echo "Usage: dockerex [$COMMANDS_STR] [SERVICE...|all]"
            ;;
    esac

}


dockerex-ls() {
    shift

    if [[ $# -ne 0 ]]; then
        echo "Too many arguments."
        return
    fi

    for i in "$SCRIPT_DIR"/*; do
        [[ -d $i ]] && echo "$(basename "$i")"
    done
}


dockerex-action() {
    action="$1"
    shift

    # INFO: in bash, $# and $@ are always up to date

    if [[ $1 == 'all' ]]; then
        # all action mode
        # catch error
        if [[ $# -gt 1 ]]; then
            echo "No additional arguments allowed when specifying 'all'."
            return
        fi
        # set positional args
        args=()
        for i in "$SCRIPT_DIR"/*; do
            [[ -d $i ]] && args+=( "$(basename "$i")" )
        done
        set -- "${args[@]}"
    else
        # normal action mode
        # catch error
        if [[ $# -eq 0 ]]; then
            echo "Not enough arguments."
            echo "Usage: dockerex $SERVICE_ACTIONS_STR SERVICE...|all"
            return
        fi
    fi

    # $@ now contains exactly the specified services
    is_first=true
    for service in "$@"; do
        [[ ! $is_first ]] && echo ""  # print newline only if not first item

        # check for errors
        if [[ ! -d $SCRIPT_DIR/$service ]]; then
            echo "Service '$service' does not exist."
            echo "Use 'dockerex ls' to list available services."
        elif ! element_in "$action" "${SERVICE_ACTIONS[@]}"; then
            echo "Invalid action."
        else
            # execute action scripts
            echo "${action^^} $service"
            "$SCRIPT_DIR/$service/$action.sh"
        fi
        is_first=
    done
}
