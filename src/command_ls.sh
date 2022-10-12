#!/bin/bash

if [[ $LS_SH ]]; then return; fi
LS_SH=true

command_ls() {
    shift

    if [[ $# -gt 0 ]]; then echo "Too many arguments."; exit 1; fi

    get_services; local services=("${retval[@]}")
    local service
    for service in "${services[@]}"; do
        echo "$service"
    done
}

# returns array of services
get_services() {
    local args=()
    for i in "$SERVICE_DIR"/*; do
        [[ -d $i ]] && args+=( "$(basename "$i")" )
    done
    retval=("${args[@]}")  # copy array
}
