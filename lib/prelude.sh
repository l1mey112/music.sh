#!/usr/bin/env bash

set -o errexit # exit on nonzero code
set -o nounset
set -o pipefail # exit code of the last command to fail, not the last command
set -o errtrace 

_failure() {
	local exit_code=$?
	local line_no=$1
	local command="$2"

	echo >&2 "${BASH_SOURCE[1]}:$line_no: '$command' failed with exit code $exit_code"

	if [ ${#FUNCNAME[@]} -gt 2 ]; then
		for ((i=1; i<${#FUNCNAME[@]}-1; i++)); do
			echo >&2 "  $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} -> ${FUNCNAME[$i]}()"
		done
	fi
	exit "$exit_code"
}

trap '_failure ${LINENO} "$BASH_COMMAND"' ERR

log() {
	echo >&2 "[INFO] ${1}"
}

assert_fail() {
	local msg="${1:-"no message provided"}"
	local line="${BASH_LINENO[0]}"
	local file="${BASH_SOURCE[1]}"
	
	echo >&2 "[ERROR] assertion failed in ${file} at line ${line}: ${msg}"
	exit 1
}
