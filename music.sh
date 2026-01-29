#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
readonly SCRIPT_DIR

STORE="$SCRIPT_DIR/store"
readonly STORE

source "$SCRIPT_DIR/lib/prelude.sh"
source "$SCRIPT_DIR/lib/path.sh"

handle_seed() {
    readonly MUSIC_TXT="$1"


}

handle_seed "$SCRIPT_DIR/music.txt"