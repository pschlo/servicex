

# receives single service as input
# reads backups.cfg and runs every backup command
# command is the only key whose value is taken literally
# WARN: key value pairs are NOT considered in the order they appear in; however, the command is always executed last
action_backup() {
    local SERVICE_CONFIG="$SERVICE_DIR/$SERVICE/backups.cfg"
    local GENERAL_CONFIG="./backups.cfg"
    local TMPFILE='.tmpfile'
    local command=

    # get service-specific config sections
    get_ini "$SERVICE_CONFIG"; declare -a sections="$(get_dec retval)"

    local section
    for section in "${sections[@]}"; do
        # merge service-specific options and general options; service options override general options
        get_ini "$SERVICE_CONFIG" "$section"; service_dict_str=$(get_dec retval)
        get_ini "$GENERAL_CONFIG" "$section"; general_dict_str=$(get_dec retval)
        merge_dicts "$general_dict_str" "$service_dict_str"; declare -A merged_dict=$(get_dec retval)

        init
        command=':'
        local key
        for key in "${!merged_dict[@]}"; do
            local value="${merged_dict[$key]}"
            if [[ $key == 'command' ]]; then command="$value"; continue; fi
            # TODO: reverse approach; get escaped assignment string with declare -p and then un-escape $
            if has_illegal_esc "$value"; then echo "Illegal escape: $value"; return 1; fi
            escape_special_chars "$value"; value="$retval"
            add_key_value "$key" "$value"
            echo "[$section] $key = $value"
        done
        execute "$command"
    done
}


# $1: command to execute
execute() {
    # execute in new shell, i.e. without inheriting variables; exit when any error occurs
    echo "$1" >>"$TMPFILE"
    bash -e "$TMPFILE"
}

# $1: key
# $2: value
add_key_value() {
    echo "export $1=\"$2\"" >>"$TMPFILE"
}


init() {
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
    unset retval
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

