#!/bin/bash

if [[ $MAIN_SH ]]; then exit; fi
MAIN_SH=true

# 1: script/action to run
# 2,3,...: services
main() {
    command="${1,,}"  # ignore case
    shift
    #set -- "$command" "$@"  # update positional args

    # using variable in case pattern; see https://stackoverflow.com/q/13254425
    case "$command" in
        ls )
            command_ls "$@" ;;
        @($SERVICE_ACTIONS_STR) )
            command_action "$command" "$@" ;;
        * )
            echo "Invalid command."
            echo "Usage: dockerex [$COMMANDS_STR] [SERVICE...|all]"
            exit 1
            ;;
    esac
}

