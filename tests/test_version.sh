#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/src/url-parser.sh"

version="$(get_version)"
if [[ "${version}" != "${URL_PARSER_VERSION}" ]]; then
    echo "FAIL: get_version does not match URL_PARSER_VERSION" >&2
    exit 1
fi

if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+ ]]; then
    echo "FAIL: version is not dotted semver (major.minor…): ${version}" >&2
    exit 1
fi

major="${version%%.*}"
rest="${version#*.}"
minor="${rest%%[.-]*}"
if [[ ! "${major}" =~ ^[0-9]+$ || ! "${minor}" =~ ^[0-9]+$ ]]; then
    echo "FAIL: major/minor are not numeric: ${version}" >&2
    exit 1
fi

echo "PASS: test_version.sh"
