#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
readonly SCRIPT_DIR

# PARAMETERS {{

readonly JOBS=${JOBS:-4}
readonly DATA_DIR=${DATA_DIR:-"$SCRIPT_DIR/music"}

# TODO: add a fuzz factor as well
readonly RECHECK_INTERVAL=${RECHECK_INTERVAL:-$((1 * SECONDS_HOUR))}

# }}

source "$SCRIPT_DIR/lib/prelude.sh"
source "$SCRIPT_DIR/lib/path.sh"

handle_seed_playlist_list() {
	readonly ARTIST="$1"
	readonly PLAYLIST_LIST_URL="$2"

	local output
	output=$(yt-dlp --flat-playlist --print "%(webpage_url)s" "$PLAYLIST_LIST_URL" 2>/dev/null)
	local ytdlp_status=$?

	if [[ $ytdlp_status -ne 0 ]]; then
		err "  -> yt-dlp failed for this seed file (exit code: $ytdlp_status)"
		return
	fi

	if [[ -z "$output" ]]; then
		log "  -> no playlists discovered"
		return
	fi

	local playlist_data
	mapfile -t playlist_data <<< "$output"
	for line in "${playlist_data[@]}"; do
		# (artist, playlist)
		echo "$ARTIST;$line"
	done

	log "  -> got ${#playlist_data[@]} playlists"
}

download_playlist() {
	local URL="$1"
}
export -f download_playlist # parallel

handle_download_playlist() {
	readonly URLS=("$@")

	parallel \
		--jobs "$JOBS" \
		--line-buffer \
		download_playlist {} ::: "${URLS[@]}"
}

handle_seed() {
	readonly SEED="$1"
	log "seed file $SEED"

	# artist;url
	local urls
	declare -a urls

	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ -z "$line" ]]; then
			artist=""
			continue
		elif [[ "$line" == Artist:* ]]; then
			artist="${line#Artist: }"
			continue
		fi

		[[ -n $artist ]] || assert "seed file is malformed: Artist in the wrong order, must be first"

		if [[ "$line" == Playlist:* ]]; then
			playlist="${line#Playlist: }"
			log "(seed \"$artist\") $playlist"

			# (artist, playlist)
			urls=( "${urls[@]}" "$artist;$playlist" )
		fi

		if [[ "$line" == Playlists:* ]]; then
			playlist_list="${line#Playlists: }"
			log "(seed list \"$artist\") $playlist_list"
		
			output=$(handle_seed_playlist_list "$artist" "$playlist_list")
			mapfile -t output_list <<< "$output"
			urls=( "${urls[@]}" "${output_list[@]}" )
		fi
	done < <(recsel -e "Epoch < $(date +'%s') - $RECHECK_INTERVAL" -p Artist,Playlist,Playlists "$SEED")

	handle_download_playlist "${urls[@]}"
}

# previously music.sh downloaded by youtube id, this goes by playlist now.
# yt-dlp can do more of the heavy lifting, and this script gets simpler

handle_seed "$DATA_DIR/Seed.rec"
