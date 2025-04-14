#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

# Define usage, help info, etc.

declare -r usage="Usage: $script_name"

apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

usage_error() {
  apprise ERROR "$1" || true
  printf >&2 '%s\n' "$usage" || true
  exit 2
}

general_error() {
  apprise ERROR "$1" || true
  exit 1
}

if (($# != 0)); then
  usage_error "Incorrect usage."
fi

# Error out if git is unavailable
if ! command -v git > /dev/null 2>&1; then
  general_error "Git is not installed or not found in PATH."
fi

# 'stat' alias -- Show working tree status in short format with branch info
# Arguments:
#   status                 # Show the working tree status
#   --short                # Output in the short-format
#   --branch               # Show branch information
git config --global \
  alias.stat \
  '
  status
    --short
    --branch
  '

# 'lg' alias -- Show commit logs in a condensed single line per commit
# Arguments:
#   --oneline             # Condense each commit to a single line
git config --global \
  alias.lg \
  '
  log
    --oneline
  '

# 'graph' alias -- Show commit logs with an ASCII graph of branch and merge history
# Arguments:
#   --graph               # Display an ASCII graph of the branch and merge history
git config --global \
  alias.graph \
  '
  log
    --graph
  '

# 'long-graph' alias -- Show commit logs with cumulative counts, compact summary, and ASCII graph
# Arguments:
#   --graph               # Display an ASCII graph of the branch and merge history
#   --compact-summary     # Display a compact summary of the commit log
#   --cumulative          # Display cumulative commit counts
git config --global \
  alias.long-graph \
  '
  log
    --graph
    --compact-summary
    --cumulative
  '

# 'log-diff' alias -- Show commit logs with full diff and various diff options
# Arguments:
#   --full-diff                  # Display full diff
#   --unified=1                  # Show diff with one line of context
#   --color=always               # Always show colored diff
#   --ignore-blank-lines         # Ignore changes whose lines are all blank
#   --ignore-space-at-eol        # Ignore changes in whitespace at EOL
#   --diff-algorithm=histogram   # Use histogram diff algorithm
#   --find-renames=50            # Detect renames with a threshold of 50%
#   --find-copies=50             # Detect copies with a threshold of 50%
#   --color-moved=zebra          # Highlight moved lines in a "zebra" pattern
#   --color-moved-ws             # Highlight moved whitespace
git config --global \
  alias.log-diff \
  '
  log
    --full-diff
    --unified=1
    --color=always
    --ignore-blank-lines
    --ignore-space-at-eol
    --diff-algorithm=histogram
    --find-renames=50
    --find-copies=50
    --color-moved=zebra
    --color-moved-ws
  '

git config --global \
  alias.cute-log \
  '
  log --pretty=tformat:"%C(bold)%C(green)<%h>%C(italic)%(decorate:prefix=  ,suffix=,pointer=→)%n%C(bold)%C(cyan)%aI  %C(italic)--%an%n%C(dim)%s%n"
  '
