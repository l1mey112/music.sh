#!/usr/bin/env bash

set -o errexit # exit on nonzero code
set -o nounset
set -o pipefail # exit code of the last command to fail, not the last command

JOBS=${JOBS:-8}
readonly JOBS

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

# parallel
export -f log
export -f err
export -f die
