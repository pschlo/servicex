#!/bin/bash

# first blanks, then comment
PATTERN_IGNORE='^[[:blank:]]*(#.*)?$'
# first blanks, then [, then blanks, then section (any characters, but ending in non-blank), then blanks, then ], then blanks
PATTERN_SECTION='^[[:blank:]]*\[[[:blank:]]*(.+[^[:blank:]])[[:blank:]]*\][[:blank:]]*$'
# first blanks, then key (underscore/letters/numbers), then blanks, then =, then blanks, then value (any characters, but ending in non-blank character), then blanks
PATTERN_KEY_VALUE='^[[:blank:]]*([_[:alnum:]]+)[[:blank:]]*=[[:blank:]]*(.*[^[:blank:]])[[:blank:]]*$'


get_ini() {
    local inifile="$1"
    local section="$2"
    local key
    local sections=()
    declare -A dict
    local is_section=

    while IFS= read -r line; do
        if [[ $line =~ $PATTERN_IGNORE ]]; then
            continue
        elif [[ $line =~ $PATTERN_SECTION ]]; then
            # listing sections
            if ! [[ $section ]]; then sections+=("${BASH_REMATCH[1]}")
            # not listing sections; check if right section
            elif [[ "${BASH_REMATCH[1]}" == "$section" ]]; then is_section=true
            else is_section=
            fi
        elif [[ $line =~ $PATTERN_KEY_VALUE ]]; then
            # continue if listing sections or if not in correct section
            if [[ ! $section || ! $is_section ]]; then continue; fi
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            dict["$key"]="$value"
        else
            echo "ERROR: Invalid line in backups.cfg: $line"
            return 1
        fi
    done < "$1"

    if [[ $section ]]; then
        cp_var dict retval
    else
        cp_var sections retval
    fi
}
