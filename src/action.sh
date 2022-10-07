#!/bin/bash

if [[ $ACTION_SH ]]; then return; fi
ACTION_SH=true


dockerex-action() {
    local action="$1"
    shift

    # get available services
    get_services
    avail_services=("${retval[@]}")


    ### parse services
    local services
    if [[ $1 == 'all' ]]; then
        # check arguments
        if [[ $# -gt 1 ]]; then echo "No additional arguments allowed when specifying 'all'."; exit 1; fi
        # check if any services available
        if [[ ${#avail_services[@]} -eq 0 ]]; then echo "No services available."; exit 1; fi
        services=("${avail_services[@]}")
    else
        # check arguments
        if [[ $# -eq 0 ]]; then echo -e "Not enough arguments.\nUsage: dockerex $SERVICE_ACTIONS_STR SERVICE...|all"; exit 1; fi
        # get services from positional args
        services=("$@")
    fi

    if ! element_in "$action" "${SERVICE_ACTIONS[@]}"; then echo "Invalid action."; exit 1; fi

    ### execute action
    local service is_first=true
    for service in "${services[@]}"; do
        [[ ! $is_first ]] && echo ""  # print newline only if not first item

        # check if service exists
        if ! element_in "$service" "${avail_services[@]}"; then echo -e "Service '$service' does not exist.\nUse 'dockerex ls' to list available services."; continue; fi

        # execute action scripts
        # services can refer to "." as their service directory and to $SERVICE as their service name
        echo "${action^^} $service"
        SERVICE="$service"
        old_pwd="$PWD"
        cd "$SERVICE_DIR/$service" >/dev/null 2>&1
        # execute in subshell so that variables and functions are inherited, but cannot be changed
        (source "./${action}.sh" 2>&1 | indent)
        # this is ok because pipefail is set
        if [[ $? -eq 0 ]]; then echo "OK"; else echo "ERROR"; fi
        cd "$old_pwd" >/dev/null 2>&1

        is_first=
    done
}

