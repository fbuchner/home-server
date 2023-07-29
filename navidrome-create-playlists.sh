#!/bin/bash

for d in /usr/media/music/*/; do
   echo "$d"
   ls "$d"/*.mp3 > "$d/$(basename "$d").m3u"
done
