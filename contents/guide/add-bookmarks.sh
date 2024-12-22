#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

bookmark_file="${HOME}/.config/gtk-3.0/bookmarks"
_desc="Add Nautilus bookmarks."
_usage="Usage: $0 <name1>=<path1> [...]"

bookmarks::help() {
    printf '%s\n%s\n' "$_desc" "$_usage"
    exit 0
}

bookmarks::usage() {
  >&2 printf '%s\n%s\n' "$_desc" "$_usage"
  exit 2
}

# Function to add a bookmark
bookmarks::add() {
    local path="$1"
    local name="$2"
    local bookmark_entry="file://$path $name"

    # Add only if it doesn't already exist
    if ! grep -q "$bookmark_entry" "$bookmark_file"; then
        echo "$bookmark_entry" >> "$bookmark_file"
        >&2 echo "Added bookmark $name → $path."
    else
        >&2 echo "Bookmark $name → $path already exists."
    fi
}

(( $# == 1 )) && [[ "$1" == "--help" ]] && bookmarks::help
(( $# == 0 )) && bookmarks::usage

for arg in "$@"; do
    IFS='=' read -r name path <<< "${arg}"
    [[ -z "$name" || -z "$path" ]] && bookmarks::usage
    bookmarks::add "$name" "$path"
done
>&2 echo "Finished adding bookmarks."
