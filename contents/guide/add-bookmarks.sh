#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
__z=$(basename "$0")
declare -r prog_name=$__z
declare -r info="Add Nautilus bookmarks."
declare -r usage="Usage: $prog_name <name1>=<path1>..."
declare -r example="Example: $prog_name \"XDG_DESKTOP_DIR=$HOME/Desktop\" \"XDG_DOWNLOAD_DIR=$HOME/Desktop\""
declare -r bookmark_file="$HOME/.config/gtk-3.0/bookmarks"

# Function to add a bookmark
bookmarks::add() {
  local path="$1"
  local name="$2"
  local bookmark_entry="file://$path $name"
  # Add only if it doesn't already exist
  if ! grep --quiet "$bookmark_entry" "$bookmark_file"; then
    printf '%s\n' "$bookmark_entry" >> "$bookmark_file"
    >&2 printf 'Added bookmark %s → %s.\n' "$name" "$path"
  else
    >&2 printf 'Bookmark %s → %s already exists.\n' "$name" "$path"
  fi
}

if (( $# == 0 )); then
  printf '%s\n%s\n' "$usage" "$example"
  exit 2
fi
if (( $# == 1 )) && [[ "$1" == "--help" ]]; then
  printf '%s\n%s\n%s\n%s\n' "$prog_name" "$info" "$usage" "$example"
  exit 0
fi

for arg in "$@"; do
  IFS='=' read -r name path <<< "$arg"
  if [[ -z "$name" ]] || [[ -z "$path" ]]; then
    >&2 printf "Invalid name=path syntax: '%s'\n%s\n%s\n" "$arg" "$usage" "$example"
  fi
  bookmarks::add "$name" "$path" || exit $?
done
>&2 printf 'Finished adding %s bookmarks.\n' "$#"
