#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

declare -r description="\
Description:
  Adds Nautilus bookmarks.
"

declare -r usage="\
Usage:
  $script_name ---help
  $script_name <name1>=<path1>...

Options:
  -h, --help    Show this message and exit.

Example:
  $script_name \\
    \"XDG_DESKTOP_DIR=$HOME/Desktop\" \\
    \"XDG_DOWNLOAD_DIR=$HOME/Downloads\"
"

apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

usage_error() {
  apprise ERROR "$1" || true
  printf >&2 '%s\n' "$usage" || true
  exit 2
}

# Parse arguments.

declare -r bookmark_file="$HOME/.config/gtk-3.0/bookmarks"

if (($# == 0)); then
  usage_error "Incorrect usage."
fi
if (($# == 1)) && [[ "$1" == "--help" || "$1" == "-h" ]]; then
  printf '%s\n%s\n' "$description" "$usage"
  exit 0
fi

# Function to add a bookmark
add() {
  local path="$1"
  local name="$2"
  local bookmark_entry="file://$path $name"
  # Add only if it doesn't already exist
  if ! grep --quiet "$bookmark_entry" "$bookmark_file"; then
    printf '%s\n' "$bookmark_entry" >> "$bookmark_file"
    apprise INFO "Added bookmark $name → $path."
  else
    apprise INFO "Bookmark $name → $path already exists."
  fi
}

for arg in "$@"; do
  IFS='=' read -r name path <<< "$arg"
  if [[ -z "$name" || -z "$path" ]]; then
    usage_error "Invalid name=path syntax: '$arg'."
  fi
  add "$name" "$path" || exit $?
done
apprise INFO "Finished adding $# bookmarks."
