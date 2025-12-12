#!/bin/bash

# Prompt user for input using Wofi

input=$(wofi --dmenu -L 1 -n --prompt="Search with Google: ")



# Debug: Show what was input

echo "Input was: $input"

search_query="$input"  # Use the whole input for search

# Trim any leading/trailing whitespace

search_query=$(echo "$search_query" | xargs)

# URL-encode the search query

search_query=$(echo "$search_query" | jq -sRr @uri)

# Open Firefox with the Google search
length=${#input}
if ((length != 0)); then
    echo "$length"
    xdg-open "https://www.google.com/search?q=$search_query" &
else
    echo "Empty input"
fi

