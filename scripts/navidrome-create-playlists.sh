#!/bin/bash

# This script iterates over all subfolders in the given path
# and creates an m3u-playlist with the mp3s for each subfolder

set -e

music_dir="/usr/media/music"

# Check if the music directory exists
if [ ! -d "$music_dir" ]; then
    echo "Music directory does not exist: $music_dir"
    exit 1
fi

for d in "$music_dir"/*/; do
    # Skip if no directories found (glob didn't match)
    [ -d "$d" ] || continue

    playlist_name="$(basename "$d").m3u"
    playlist_path="$d$playlist_name"

    # Find mp3 files and create playlist with relative paths
    if compgen -G "$d"/*.mp3 > /dev/null; then
        # Create playlist with filenames only (relative to the directory)
        (cd "$d" && ls -1 *.mp3) > "$playlist_path"
        echo "Created: $playlist_path"
    else
        echo "No mp3 files in: $d"
    fi
done

echo "Playlist creation complete."
