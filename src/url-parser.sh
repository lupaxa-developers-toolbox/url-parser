#!/usr/bin/env bash
# shellcheck disable=SC2034

# -------------------------------------------------------------------------------- #
# Description                                                                      #
# -------------------------------------------------------------------------------- #
# Bash URL splitter. Fills URL_* globals from one input string.                    #
# -------------------------------------------------------------------------------- #

URL_PARSER_VERSION="0.1.0"

URL=""
URL_PROTOCOL=""
URL_USER=""
URL_PASS=""
URL_HOST=""
URL_PORT=""
URL_PATH=""
URL_QUERY=""
URL_FRAGMENT=""

get_version()
{
    printf '%s\n' "${URL_PARSER_VERSION}"
}

# Scheme name only. Add a scheme by adding one arm.
default_port_for_scheme()
{
    local scheme="$1"

    case "${scheme}" in
        http) printf '%s' "80" ;;
        https) printf '%s' "443" ;;
        ssh) printf '%s' "22" ;;
        sftp) printf '%s' "22" ;;
        ftp) printf '%s' "21" ;;
        ftps) printf '%s' "990" ;;
        git) printf '%s' "9418" ;;
        *) printf '%s' "" ;;
    esac
}

# Decode %HH sequences. %00 is left unchanged because Bash cannot store a NUL.
_url_decode_assign()
{
    local name="$1"
    local value="$2"
    local decoded=""
    local index=0
    local character=""
    local hex=""
    local byte=""

    while [[ "${index}" -lt "${#value}" ]]; do
        character="${value:index:1}"
        if [[ "${character}" == "%" ]]; then
            hex="${value:index+1:2}"
            if [[ "${#hex}" -eq 2 && "${hex}" =~ ^[0-9A-Fa-f]{2}$ && "${hex}" != "00" ]]; then
                printf -v byte '%b' "\\x${hex}"
                decoded+="${byte}"
                index=$((index + 3))
                continue
            fi
        fi
        decoded+="${character}"
        index=$((index + 1))
    done
    printf -v "${name}" '%s' "${decoded}"
}

_url_decode_fields()
{
    _url_decode_assign URL_USER "${URL_USER}"
    _url_decode_assign URL_PASS "${URL_PASS}"
    _url_decode_assign URL_HOST "${URL_HOST}"
    _url_decode_assign URL_PATH "${URL_PATH}"
    _url_decode_assign URL_QUERY "${URL_QUERY}"
    _url_decode_assign URL_FRAGMENT "${URL_FRAGMENT}"
}

_url_split_userinfo()
{
    local userinfo="$1"

    if [[ "${userinfo}" == *:* ]]; then
        URL_USER="${userinfo%%:*}"
        URL_PASS="${userinfo#*:}"
    else
        URL_USER="${userinfo}"
        URL_PASS=""
    fi
}

_url_split_hostport()
{
    local hostport="$1"
    local after_bracket=""

    URL_HOST=""
    URL_PORT=""

    if [[ "${hostport}" == \[*\]* ]]; then
        URL_HOST="${hostport#\[}"
        URL_HOST="${URL_HOST%%\]*}"
        after_bracket="${hostport#*\]}"
        if [[ "${after_bracket}" == :* ]]; then
            URL_PORT="${after_bracket#:}"
        fi
        return 0
    fi

    if [[ "${hostport}" == *:* ]]; then
        URL_HOST="${hostport%%:*}"
        URL_PORT="${hostport#*:}"
    else
        URL_HOST="${hostport}"
    fi
}

_url_apply_default_port()
{
    if [[ -z "${URL_PORT}" ]]; then
        URL_PORT="$(default_port_for_scheme "${URL_PROTOCOL}")"
    fi
}

parse_url()
{
    local input="$1"
    local rest=""
    local body=""
    local authority=""
    local hostport=""

    URL="${input}"
    URL_PROTOCOL=""
    URL_USER=""
    URL_PASS=""
    URL_HOST=""
    URL_PORT=""
    URL_PATH=""
    URL_QUERY=""
    URL_FRAGMENT=""

    rest="${input}"
    if [[ "${rest}" == *"#"* ]]; then
        URL_FRAGMENT="${rest#*#}"
        rest="${rest%%#*}"
    fi
    if [[ "${rest}" == *"?"* ]]; then
        URL_QUERY="${rest#*\?}"
        rest="${rest%%\?*}"
    fi

    # scp-style git@host:path has no scheme. The colon introduces the path.
    if [[ "${rest}" != *"://"* && "${rest}" == git@* ]]; then
        URL_USER="git"
        URL_PORT="22"
        rest="${rest#git@}"
        if [[ "${rest}" == *:* ]]; then
            URL_HOST="${rest%%:*}"
            URL_PATH="${rest#*:}"
        else
            URL_HOST="${rest}"
        fi
        _url_decode_fields
        return 0
    fi

    if [[ "${rest}" == *"://"* ]]; then
        URL_PROTOCOL="$(printf '%s' "${rest%%://*}" | tr '[:upper:]' '[:lower:]')"
        body="${rest#*://}"
    else
        body="${rest}"
    fi

    if [[ "${body}" == */* ]]; then
        authority="${body%%/*}"
        URL_PATH="/${body#*/}"
    else
        authority="${body}"
    fi

    if [[ -n "${authority}" && "${authority}" == *@* ]]; then
        _url_split_userinfo "${authority%@*}"
        hostport="${authority##*@}"
    else
        hostport="${authority}"
    fi

    _url_split_hostport "${hostport}"
    _url_apply_default_port
    _url_decode_fields
}
