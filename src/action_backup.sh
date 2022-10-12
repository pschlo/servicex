


## regex patterns

PATTERN_SINGLE_QUOTE="'"
# first blanks, then comment
PATTERN_IGNORE='^[[:blank:]]*(#.*)?$'
# first blanks, then [, then blanks, then section (any characters, but ending in non-blank), then blanks, then ], then blanks
PATTERN_SECTION='^[[:blank:]]*\[[[:blank:]]*(.+[^[:blank:]])[[:blank:]]*\][[:blank:]]*$'
# first blanks, then key (underscore/letters/numbers), then blanks, then =, then blanks, then value (any characters, but ending in non-blank character), then blanks
PATTERN_KEY_VALUE='^[[:blank:]]*([_[:alnum:]]+)[[:blank:]]*=[[:blank:]]*(.*[^[:blank:]])[[:blank:]]*$'


TMPFILE='.tmpfile'
section=

# receives single service as input
# reads backups.cfg and runs every backup command
# command is the only key whose value is taken literally
action_backup() {
    init
    while IFS= read -r line; do
        if [[ $line =~ $PATTERN_IGNORE ]]; then
            continue
        elif [[ $line =~ $PATTERN_SECTION ]]; then
            section="${BASH_REMATCH[1]}"
            execute
            init  # reset
        elif [[ $line =~ $PATTERN_KEY_VALUE ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            if [[ $key == 'command' ]]; then command="$value"; continue; fi
            if has_illegal_esc "$value"; then echo "Illegal escape: $value"; return 1; fi
            escape_special_chars "$value"; value="$retval"
            add_key_value "$key" "$value"
            echo "[$section] $key=$value"
        else
            echo "ERROR: Invalid line in backups.cfg: $line"
            return 1
        fi
    done < "./backups.cfg"
    execute
}


execute() {
    # execute in new shell, i.e. without inheriting variables
    echo "$command" >>"$TMPFILE"
    bash "$TMPFILE"
}

# $1: key
# $2: value
add_key_value() {
    echo "export $1=\"$2\"" >>"$TMPFILE"
}


init() {
    command=
    >"$TMPFILE"
    echo "source ./src/utils.sh" >>"$TMPFILE"
    echo "SERVICE='$SERVICE'" >>"$TMPFILE"
}


# $1: value
has_illegal_esc() {
    # check if anything other than $ and \ is escaped
    local ESC_CHARS='$\'
    local PATTERN_ILLEGAL_ESC='(^|[^'$ESC_CHARS'])(\\\\)*\\([^'$ESC_CHARS']|$)'
    [[ $1 =~ $PATTERN_ILLEGAL_ESC ]]
}


# $1: value
escape_special_chars() {
#    local SED_ESC_BACKSLASH='s/\\/\\\\/g'
    local SED_ESC_DOUBLE_QUOTE='s/"/\\"/g'
#    local SED_ESC_SUBSHELL='s/\$(/\\\$(/g'
    local SED_ESC_BACKTICK='s/`//g'
#    local SED_QUOTE_VARS='s/\$[^[:blank:]]*/"&"/g'
    # RULE: dollar signs and backslashes must be escaped by backslash! Everything else is treated literally
    # backslash may only escape dollar sign and backslash
    # only $ followed with non-space characters may be used and is automatically quoted
    retval="$(echo "$1" | sed -E -e "$SED_ESC_DOUBLE_QUOTE" -e "$SED_ESC_BACKTICK")"
}



#key="$(echo "$key" | trim)"
#        if contains_space "$key"; then echo "ERROR: key '$key' contains whitespace"; return 1; fi
#        value="$(echo "$value" | trim)"
#
#        if [[ $key == \[*] || $is_done ]]; then
#            # found section
#            section="$key"
#            str+='; eval "$command"'
#            # execute in new shell with clean env
#            env -i SERVICE="$1" bash -c "$str"
#            # reset
#            str=":"
#        elif [[ $value ]]; then
#            # found key value pair
#            str+="; declare '$key'='$value'"
#        fi
#
#        if [[ $is_done ]]; then break; fi
#    done < "./backups.cfg"
#}
