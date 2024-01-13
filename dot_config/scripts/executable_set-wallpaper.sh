#!/usr/bin/env bash

screen_size=$(xrandr | grep ' connected' | awk '{print $3}' | cut -f1 -d"+")

IFS=$'\n'
readarray -t <<<"$screen_size"
feh_command="wal"

for i in "${MAPFILE[@]}"
do
    echo size: "$i"
    feh_command="$feh_command -i $HOME/Pictures/wallpapers/Celeste/Celeste_Space--$i.png"
done

eval "$feh_command" &
disown
