#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "${ROOT}/src/url-parser.sh"

FAILS=0

assert_eq() {
    local got="$1"
    local want="$2"
    local name="$3"
    if [[ "${got}" == "${want}" ]]; then
        printf 'PASS  %s\n' "${name}"
        return 0
    fi
    printf 'FAIL  %s\n' "${name}"
    printf '      got:  [%s]\n' "${got}"
    printf '      want: [%s]\n' "${want}"
    FAILS=$((FAILS + 1))
}

expect_url() {
    local name="$1"
    local input="$2"
    local protocol="$3"
    local user="$4"
    local pass="$5"
    local host="$6"
    local port="$7"
    local path="$8"
    local query="${9-}"
    local fragment="${10-}"

    parse_url "${input}"
    assert_eq "${URL}" "${input}" "${name} input"
    assert_eq "${URL_PROTOCOL}" "${protocol}" "${name} protocol"
    assert_eq "${URL_USER}" "${user}" "${name} user"
    assert_eq "${URL_PASS}" "${pass}" "${name} password"
    assert_eq "${URL_HOST}" "${host}" "${name} host"
    assert_eq "${URL_PORT}" "${port}" "${name} port"
    assert_eq "${URL_PATH}" "${path}" "${name} path"
    assert_eq "${URL_QUERY-}" "${query}" "${name} query"
    assert_eq "${URL_FRAGMENT-}" "${fragment}" "${name} fragment"
}

expect_url \
    "https path" \
    "https://github.com/example/tools.git" \
    "https" "" "" "github.com" "443" "/example/tools.git"

expect_url \
    "user password port" \
    "https://foo:12333@github.com:8080/example/tools.git" \
    "https" "foo" "12333" "github.com" "8080" "/example/tools.git"

expect_url \
    "scp git" \
    "git@github.com:briceburg/tools.git" \
    "" "git" "" "github.com" "22" "briceburg/tools.git"

expect_url \
    "email user" \
    "https://me@gmail.com:12345@my.site.com:443/p/a/t/h" \
    "https" "me@gmail.com" "12345" "my.site.com" "443" "/p/a/t/h"

expect_url \
    "clears previous password" \
    "https://github.com/example/tools.git" \
    "https" "" "" "github.com" "443" "/example/tools.git"

expect_url \
    "http default port" \
    "http://example.com/a" \
    "http" "" "" "example.com" "80" "/a"

expect_url \
    "ssh default port" \
    "ssh://git@github.com/org/repo.git" \
    "ssh" "git" "" "github.com" "22" "/org/repo.git"

expect_url \
    "ssh explicit port" \
    "ssh://git@github.com:2222/org/repo.git" \
    "ssh" "git" "" "github.com" "2222" "/org/repo.git"

expect_url \
    "ftp default port" \
    "ftp://files.example.com/pub/a" \
    "ftp" "" "" "files.example.com" "21" "/pub/a"

expect_url \
    "ftp explicit port" \
    "ftp://files.example.com:2121/pub/a" \
    "ftp" "" "" "files.example.com" "2121" "/pub/a"

expect_url \
    "ftps default port" \
    "ftps://user:secret@files.example.com/pub/a" \
    "ftps" "user" "secret" "files.example.com" "990" "/pub/a"

expect_url \
    "unknown scheme" \
    "custom://host/path" \
    "custom" "" "" "host" "" "/path"

expect_url \
    "password colons" \
    "https://user:p:ass@host/path" \
    "https" "user" "p:ass" "host" "443" "/path"

expect_url \
    "query and fragment" \
    "https://example.com/a/b?x=1#frag" \
    "https" "" "" "example.com" "443" "/a/b" "x=1" "frag"

expect_url \
    "fragment keeps question mark" \
    "https://example.com/a#frag?still" \
    "https" "" "" "example.com" "443" "/a" "" "frag?still"

expect_url \
    "trailing slash" \
    "https://example.com/" \
    "https" "" "" "example.com" "443" "/"

expect_url \
    "no path" \
    "https://example.com" \
    "https" "" "" "example.com" "443" ""

expect_url \
    "ipv6" \
    "http://[::1]/path" \
    "http" "" "" "::1" "80" "/path"

expect_url \
    "ipv6 explicit port" \
    "http://[::1]:8080/path" \
    "http" "" "" "::1" "8080" "/path"

expect_url \
    "ipv6 userinfo" \
    "https://user:secret@[2001:db8::1]:8443/a" \
    "https" "user" "secret" "2001:db8::1" "8443" "/a"

expect_url \
    "sftp default port" \
    "sftp://user@files.example.com/pub/a" \
    "sftp" "user" "" "files.example.com" "22" "/pub/a"

expect_url \
    "git scheme default port" \
    "git://github.com/example/tools.git" \
    "git" "" "" "github.com" "9418" "/example/tools.git"

expect_url \
    "file url" \
    "file:///etc/hosts" \
    "file" "" "" "" "" "/etc/hosts"

expect_url \
    "file url with host" \
    "file://localhost/etc/hosts" \
    "file" "" "" "localhost" "" "/etc/hosts"

expect_url \
    "scheme case" \
    "HTTP://Example.COM/A" \
    "http" "" "" "Example.COM" "80" "/A"

expect_url \
    "no scheme" \
    "not a url" \
    "" "" "" "not a url" "" ""

expect_url \
    "clears query and fragment" \
    "https://example.com/a" \
    "https" "" "" "example.com" "443" "/a"

expect_url \
    "percent decode" \
    "https://user%40example.com:p%3Aass@ex%61mple.com/a%20b?q=%26#f%20g" \
    "https" "user@example.com" "p:ass" "example.com" "443" "/a b" "q=&" "f g"

expect_url \
    "invalid percent left intact" \
    "https://example.com/a%2" \
    "https" "" "" "example.com" "443" "/a%2"

expect_url \
    "encoded nul left intact" \
    "https://example.com/a%00b" \
    "https" "" "" "example.com" "443" "/a%00b"

expect_url \
    "ipv6 zone id" \
    "http://[fe80::1%25eth0]/a" \
    "http" "" "" "fe80::1%eth0" "80" "/a"

if [[ "${FAILS}" -ne 0 ]]; then
    printf 'FAIL: %s assertion(s)\n' "${FAILS}" >&2
    exit 1
fi

echo "PASS: test_url_parser.sh"
