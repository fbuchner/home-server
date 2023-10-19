#!/bin/bash

# This script iterates over all subfolders in the given path 
# and creates an m3u-playlist with the mp3s for each subfolder 

for d in /usr/media/music/*/; do
   echo "$d"
   ls "$d"/*.mp3 > "$d/$(basename "$d").m3u"
done
