#!/bin/sh

player_status=$(playerctl status 2> /dev/null)
artist=$(playerctl metadata artist 2> /dev/null)
title=$(playerctl metadata title 2> /dev/null)

# Remove "- Topic" suffix, if it exists at the end of the artist name.
artist=$(echo "$artist" | sed -E 's/\s*-\s*Topic$//')

# Clean up the title
cleaned_title=$(echo "$title" | \
    # Remove "(Official Audio)", "(Official Video)", etc.
    sed -E 's/[-–|]?\s*(Official Audio|Official Video|Music Video|HD|4K)\s*//Ig' | \
    # Remove artist name only if it appears exactly at the start of the title, with word boundary and separator
    sed -E "s/^${artist//\//\\/}(\s*[-–|]\s*)?//I" | \
    # Remove any duplicate artist name later in the title, using word boundaries
    sed -E "s/\b${artist//\//\\/}\b\s*[-–|]?\s*//Ig" | \
    # Normalize whitespace to a single space
    sed -E 's/\s+/ /g' | \
    # Normalize multiple dashes to a single dash
    sed -E 's/[-–|]+/-/g' | \
    # Remove empty parentheses and brackets
    sed -E 's/\(\s*\)//g' | \
    sed -E 's/\[\s*\]//g' | \
    # Trim leading and trailing spaces without affecting letters like 'S' at ends
    sed -E 's/^ +| +$//g')

# Output depending on player status
if [ "$player_status" = "Playing" ]; then
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
