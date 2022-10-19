#!/bin/bash

# first blanks, then comment
PATTERN_IGNORE='^[[:blank:]]*(#.*)?$'
# first blanks, then [, then blanks, then section (any characters, but ending in non-blank), then blanks, then ], then blanks
PATTERN_SECTION='^[[:blank:]]*\[[[:blank:]]*(.+[^[:blank:]])[[:blank:]]*\][[:blank:]]*$'
# first blanks, then key (underscore/letters/numbers), then blanks, then =, then blanks, then value (any characters, but ending in non-blank character), then blanks
PATTERN_KEY_VALUE='^[[:blank:]]*([_[:alnum:]]+)[[:blank:]]*=[[:blank:]]*(.*[^[:blank:]])[[:blank:]]*$'


# TODO: since assoc arrays are not ordered, the ordering could be stored in an additional array
#       see https://stackoverflow.com/a/29161460
get_ini() {
    unset retval

    local FILE="$1" LOOKUP_SECT="$2"
    local sections=()
    declare -A dict=()
    local curr_sect=

    local line
    while IFS= read -r line; do
        if [[ $line =~ $PATTERN_IGNORE ]]; then
            continue
        elif [[ $line =~ $PATTERN_SECTION ]]; then
            curr_sect="${BASH_REMATCH[1]}"
            # check if listing sections
            if ! [[ $LOOKUP_SECT ]]; then sections+=("$curr_sect"); fi
        elif [[ $line =~ $PATTERN_KEY_VALUE ]]; then
            # catch key value appearing before any sections
            if ! [[ $curr_sect ]]; then echo "ERROR: key value pair outside of section in file $FILE: $line"; fi
            # continue if listing sections or if not in right section
            if [[ ! $LOOKUP_SECT || $curr_sect != $LOOKUP_SECT ]]; then continue; fi
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            dict["$key"]="$value"
        else
            echo "ERROR: Invalid line in config file $FILE: $line"
            exit 1
        fi
    done < "$FILE"

    if [[ $LOOKUP_SECT ]]; then
        declare -Ag retval=$(get_dec dict)
    else
        declare -ag retval=$(get_dec sections)
    fi
}
