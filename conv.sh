#!/usr/bin/env bash
#
# Copyright (C) 2026 l-m.dev
# 
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, version 3.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.

# PRELUDE {{

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

activate_prelude() {
	set -o errexit
	set -o nounset
	set -o pipefail
	set -o errtrace 
	
	# We trap the ERR signal to the _failure function
	trap '_failure ${LINENO} "$BASH_COMMAND"' ERR
}
export -f _failure log assert_fail activate_prelude

activate_prelude

# }}

show_help() {
	cat << EOF
Usage: ${0##*/} [ALBUM_ARTIST] [FILE...]
Convert audio files to MP3 and set album artist metadata.

Options:
  -h, --help                          Display this help and exit

Copyright (C) 2026 l-m.dev.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Report bugs to: <https://github.com/l1mey112/music.sh/issues>
EOF
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help) show_help; exit ;;
		-?*) assert_fail "unknown option: $1\n" ;;
		*) break ;;
	esac
	shift
done

if [[ $# -lt 2 ]]; then
	show_help
	exit 1
fi

albumartist="$1"
shift

for file in "$@"; do
	out="${file%.*}.mp3"
	
	if [[ -f "$out" ]]; then
		continue
	fi

	tmp_img="/tmp/coverart_$$_${RANDOM}.jpg"

	ffmpeg -v error -i "$file" -an -vcodec copy -f image2pipe - | \
	convert - -resize "320x320^" -gravity center -extent 320x320 \
			-strip -colorspace sRGB -type TrueColor -interlace none \
			-sampling-factor 2x2,1x1,1x1 -quality 85 "$tmp_img"

	ffmpeg -v error -i "$file" -map 0:a -c:a libmp3lame -q:a 0 -map_metadata 0 -id3v2_version 3 -y "$out"

	if [[ -f "$tmp_img" ]]; then
		eyeD3 --quiet --add-image "$tmp_img:FRONT_COVER" "$out" > /dev/null 2>&1
		rm -f "$tmp_img"
	fi

	eyeD3 --quiet --album-artist="$albumartist" "$out" > /dev/null 2>&1
done
