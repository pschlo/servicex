

# receives single service as input
# reads backups.cfg and runs every backup command
# command is the only key whose value is taken literally
action_backup() {
    local section key TMPFILE='.tmpfile' SOURCE="./backups.cfg"
    # get sections
    get_ini "$SOURCE"; cp_var retval sections
    for section in "${sections[@]}"; do
        init
        # get key-value pairs
        get_ini "$SOURCE" "$section"; cp_var retval dict
        for key in "${!dict[@]}"; do
            local value="${dict[$key]}"
            if [[ $key == 'command' ]]; then command="$value"; continue; fi
            # TODO: reverse approach; get escaped assignment string with declare -p and then un-escape $
            if has_illegal_esc "$value"; then echo "Illegal escape: $value"; return 1; fi
            escape_special_chars "$value"; cp_var retval value
            add_key_value "$key" "$value"
            echo "[$section] $key = $value"
        done
        execute
    done
}


execute() {
    # execute in new shell, i.e. without inheriting variables; exit when any error occurs
    echo "$command" >>"$TMPFILE"
    bash -e "$TMPFILE"
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

