#!/usr/bin/env bash

set -o errexit # exit on nonzero code
set -o nounset
set -o pipefail # exit code of the last command to fail, not the last command

log() {
	echo >&2 "[INFO] ${1}"
}

err() {
	echo >&2 "[ERROR] ${1}"
}

die() {
	echo >&2 "[ERROR] ${1}"
	exit 1
}

assert() {
    local msg="${1:-"no message provided"}"
    local line="${BASH_LINENO[0]}"
    local file="${BASH_SOURCE[1]}"
    
    die "assertion failed in ${file} at line ${line}: ${msg}"
}

# parallel
export -f log
export -f err
export -f die
export -f assert

readonly SECONDS_MINUTE=60
readonly SECONDS_HOUR=$((60 * SECONDS_MINUTE))
readonly SECONDS_DAY=$((24 * SECONDS_HOUR))
