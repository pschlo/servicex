#!/bin/bash

if [[ $ACTION_SH ]]; then return; fi
ACTION_SH=true


dockerex-action() {
    local action="$1"
    shift

    ### obtain services
    local services
    if [[ $1 == 'all' ]]; then
        # check arguments
        if [[ $# -gt 1 ]]; then echo "No additional arguments allowed when specifying 'all'."; exit 1; fi
        get_services; services=("${retval[@]}")
        # check if service array empty
        if [[ ${#services[@]} -eq 0 ]]; then echo "No services available."; exit 1; fi
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
        if ! dockerex-ls | grep -q "^${service}$"; then echo -e "Service '$service' does not exist.\nUse 'dockerex ls' to list available services."; continue; fi

        # execute action scripts
        # services can refer to "." as their service directory and to $SERVICE as their service name
        echo "${action^^} $service"
        export SERVICE="$service"
        old_pwd="$PWD"
        cd "$SERVICE_DIR/$service" >/dev/null 2>&1
        "./${action}.sh"
        cd "$old_pwd" >/dev/null 2>&1

        is_first=
    done
}

