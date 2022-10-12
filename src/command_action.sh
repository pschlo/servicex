#!/bin/bash

if [[ $ACTION_SH ]]; then return; fi
ACTION_SH=true


command_action() {
    local action="$1"
    shift

    # check if action is valid
    if ! element_in "$action" "${SERVICE_ACTIONS[@]}"; then echo "Invalid action."; exit 1; fi

    # get available services
    get_services; local AVAIL_SERVICES=("${retval[@]}")

    parse_services "$@"; services=("${retval[@]}")

    execute_action "$action" "${services[@]}"
}


# $1,$2,...: services from user input
parse_services() {
    if [[ $1 == 'all' ]]; then
        # check arguments
        if (( $# > 1 )); then echo "No additional arguments allowed when specifying 'all'."; exit 1; fi
        # check if any services available
        if (( ${#AVAIL_SERVICES[@]} == 0 )); then echo "No services available."; exit 1; fi
        retval=("${AVAIL_SERVICES[@]}")
    else
        # check arguments
        if (( $# == 0 )); then echo -e "Not enough arguments.\nUsage: dockerex $SERVICE_ACTIONS_STR SERVICE...|all"; exit 1; fi
        # get services from positional args
        retval=("$@")
    fi
}


# $1: action
# $2,$3,...: services
execute_action() {
    local action="$1"; shift
    local services=("$@")
    local is_first="true"

    for service in "${services[@]}"; do
        [[ ! $is_first ]] && echo ""  # print newline only if not first item

        # check if service exists
        if ! element_in "$service" "${AVAIL_SERVICES[@]}"; then echo -e "Service '$service' does not exist.\nUse 'dockerex ls' to list available services."; continue; fi

        # execute action
        # action call inherits entire env, plus $SERVICE; run in subshell
        echo "${action^^} $service"
        (SERVICE="$service" action_"$action" "$service" 2>&1 | indent)

        # this is ok because pipefail is set
        if (( $? == 0 )); then echo "OK"; else echo "ERROR"; fi

        is_first=
    done
}
