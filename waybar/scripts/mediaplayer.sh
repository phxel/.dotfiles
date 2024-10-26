#!/bin/sh

player_status=$(playerctl status 2> /dev/null)
artist=$(playerctl metadata artist 2> /dev/null)
title=$(playerctl metadata title 2> /dev/null)

artist=$(echo "$artist" | sed -E 's/\s*-\s*Topic$//')

cleaned_title=$(echo "$title" | \
    # Remove "(Official Audio)", etc.
    sed -E 's/[-–|]?\s*(Official Audio|Official Video|Music Video|HD|4K)//Ig' | \
    # Remove artist name if it appears at the start of the title
    sed -E "s/^${artist}\s*[-–|]\s*//I" | \
    # Remove any duplicate artist name anywhere in the title
    sed -E "s/\s*[-–|]\s*${artist}\s*//I" | \
    # Clean up any leftover double spaces or dashes
    sed -E 's/\s+/ /g' | \
    sed -E 's/[-–|]+/-/g' | \
    # Remove empty parentheses and brackets
    sed -E 's/\(\s*\)//g' | \
    sed -E 's/\[\s*\]//g' | \
    # Trim leading/trailing spaces, dashes, and parentheses
    sed -E 's/^[-\s()]+//;s/[-\s()]+$//')

if [ "$player_status" = "Playing" ]; then
    # Only include artist name once
    if [ "$artist" = "$cleaned_title" ]; then
        echo " $artist"
    else
        echo " $artist - $cleaned_title"
    fi
elif [ "$player_status" = "Paused" ]; then
    if [ "$artist" = "$cleaned_title" ]; then
        echo " $artist"
    else
        echo " $artist - $cleaned_title"
    fi
fi
