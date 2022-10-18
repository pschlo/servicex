#!/bin/bash

if [[ $LS_SH ]]; then return; fi
LS_SH=true

command_ls() {
    shift

    if (( $# > 0 )); then echo "Too many arguments."; exit 1; fi

    get_services; declare -a services="$(get_declare retval)"
    local service
    for service in "${services[@]}"; do
        echo "$service"
    done
}

# returns array of services
get_services() {
    local i args=()
    for i in "$SERVICE_DIR"/*; do
        [[ -d $i ]] && args+=( "$(basename "$i")" )
    done
    unset retval; declare -ag retval="$(get_declare args)"  # copy array
}
