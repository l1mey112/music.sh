#!/usr/bin/env bash

path_safe() {
	local k="$1"

	# Replace / characters with ⧸
	k="${k//\//⧸}"

	# Backslash -> Full-width Reverse Solidus
	k="${k//\\/＼}"

	k="${k//:/∶}"     # Colon -> Ratio (U+2236)
	k="${k//\[/［}"   # Left Bracket -> Full-width (U+FF3B)
	k="${k//\]/］}"   # Right Bracket -> Full-width (U+FF3D)
	
	k="${k//|/∣}"   # | -> ∣ (divides)
	
	k="${k//</＜}"   # < -> ＜ (Full-width Less-than U+FF1C)
	k="${k//>/＞}"   # > -> ＞ (Full-width Greater-than U+FF1E)
	
	# Remove :?* characters
	k="${k//[:?*]/}"
	# Replace " with '
	k="${k//\"/\'}"
	echo "$k"
}

#path_store_nf() {
#	echo "$DATA_DIR/_Store"
#	mkdir -p "$DATA_DIR/_Store"
#}

# use namerefs because the last thing we want to do is spawn 1000 subshells

path_store_shards_youtube_id() {
	local folder="$DATA_DIR/_Store"

	# https://wiki.archiveteam.org/index.php/YouTube/Technical_details
	log "creating shards _Store/[A-Za-z0-9_-]/"
	mkdir -p "$folder"/{A..Z} "$folder"/{a..z} "$folder"/{0..9} "$folder"/- "$folder"/_
}

# assumed that the correct shard already exists as a folder
# use path_store_shards_youtube_id to create them
path_store_sharded_nr() {
	local -n out=$1
	local -r ID="$2"
	local -r EXT="$3"

	# we shard by a single character. why? who knows.
	local folder="$DATA_DIR/_Store/${ID:0:1}"
	
	# https://github.com/koalaman/shellcheck/issues/2071
	# https://github.com/koalaman/shellcheck/issues/817
	# shellcheck disable=SC2034
	out="$folder/$ID$EXT"
}
