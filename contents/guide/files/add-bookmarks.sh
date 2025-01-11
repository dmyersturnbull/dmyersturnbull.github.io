#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
# SPDX-FileCopyrightText: Copyright 2024, Contributors to the dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: MIT

__z=$(basename "$0")
declare -r prog_name=$__z
declare -r prog_vr="v0.1.0"
declare -r info="\
$prog_name $prog_vr

Adds Nautilus bookmarks.
"
declare -r usage="\
Usage:
  $prog_name <name1>=<path1>...
  $prog_name -h --help

Example:
  $prog_name \\
    \"XDG_DESKTOP_DIR=$HOME/Desktop\" \\
    \"XDG_DOWNLOAD_DIR=$HOME/Downloads\"
"
declare -r bookmark_file="$HOME/.config/gtk-3.0/bookmarks"

# Function to add a bookmark
bookmarks::add() {
  local path="$1"
  local name="$2"
  local bookmark_entry="file://$path $name"
  # Add only if it doesn't already exist
  if ! grep --quiet "$bookmark_entry" "$bookmark_file"; then
    printf '%s\n' "$bookmark_entry" >> "$bookmark_file"
    printf >&2 'Added bookmark %s → %s.\n' "$name" "$path"
  else
    printf >&2 'Bookmark %s → %s already exists.\n' "$name" "$path"
  fi
}

if (($# == 0)); then
  printf '%s\n' "$usage"
  exit 2
fi
if (($# == 1)) && [[ "$1" == "--help" || "$1" == "-h" ]]; then
  printf '%s\n%s\n' "$info" "$usage"
  exit 0
fi

for arg in "$@"; do
  IFS='=' read -r name path <<< "$arg"
  if [[ -z "$name" || -z "$path" ]]; then
    printf >&2 "Invalid name=path syntax: '%s'.\n%s\n" "$arg" "$usage"
  fi
  bookmarks::add "$name" "$path" || exit $?
done
printf >&2 'Finished adding %s bookmarks.\n' "$#"
