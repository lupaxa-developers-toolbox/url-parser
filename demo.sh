#!/usr/bin/env bash

# -------------------------------------------------------------------------------- #
# Description                                                                      #
# -------------------------------------------------------------------------------- #
# Run parse_url over a set of sample URLs and print each result.                   #
# -------------------------------------------------------------------------------- #

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/src/url-parser.sh"

# parse_url fills these. Declared here so ShellCheck can see the assignments.
declare URL URL_PROTOCOL URL_USER URL_PASS URL_HOST URL_PORT URL_PATH URL_QUERY URL_FRAGMENT

URLS=(
    "https://github.com/example/tools.git"
    "https://foo:12333@github.com:8080/example/tools.git"
    "https://user:p:ass@host/path?x=1#frag"
    "git@github.com:example/tools.git"
    "https://me@gmail.com:12345@my.site.com:443/p/a/t/h"
    "ssh://git@github.com/org/repo.git"
    "ssh://git@github.com:2222/org/repo.git"
    "sftp://user@files.example.com/pub/a"
    "ftp://files.example.com/pub/a"
    "ftps://user:secret@files.example.com/pub/a"
    "git://github.com/example/tools.git"
    "http://[::1]:8080/path"
    "https://example.com/a%20b?q=1#f%20g"
    "file:///etc/hosts"
)

for sample in "${URLS[@]}"; do
    echo "-----------------------------------------------------------------------"
    parse_url "${sample}"
    echo "URL:      ${URL}"
    echo "Protocol: ${URL_PROTOCOL}"
    echo "User:     ${URL_USER}"
    echo "Password: ${URL_PASS}"
    echo "Host:     ${URL_HOST}"
    echo "Port:     ${URL_PORT}"
    echo "Path:     ${URL_PATH}"
    echo "Query:    ${URL_QUERY}"
    echo "Fragment: ${URL_FRAGMENT}"
done
