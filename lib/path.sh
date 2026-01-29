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


