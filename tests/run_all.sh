#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash tests/test_version.sh
bash tests/test_url_parser.sh
echo "PASS: all url-parser tests"
