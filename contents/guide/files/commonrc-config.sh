#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

# Source this file.
# Environment variables:
#   $COMMONRC_VERBOSE -- boolean ("true"|"false"): whether to write found/added lines to stdout.
# Functions:
#   commonrc::init
#   commonrc::add_line
#   commonrc::prepend_to_path
#   commonrc::source_from

set -o errexit -o nounset -o pipefail # "strict mode"

declare -x COMMONRC_VERBOSE="false"
declare -r commonrc_file="$HOME/.commonrc"

__commonrc_apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

commonrc::init() {
  # Creates a ~/.commonrc if it doesn't already exist.
  # The mostly blank file just adds these directories to $PATH:
  # /usr/sbin, /usr/local/sbin, and ~/bin (creating ~/bin if needed)
  # Usage:
  #   commonrc::init
  mkdir -p "$HOME/bin"
  if [[ ! -e "$commonrc_file" ]]; then
    printf '%s\n\n%s\n%s\n' \
      '# Common file sourced by ~/.bashrc, ~/.zshrc, etc.' \
      '# Configure PATH' \
      'EXPORT PATH' \
      > "$commonrc_file"
    # shellcheck disable=SC2016
    commonrc::prepend_to_path '/usr/sbin'
    commonrc::prepend_to_path '/usr/local/sbin'
    # shellcheck disable=SC2016
    commonrc::prepend_to_path '$HOME/bin'
    if [[ "$COMMONRC_VERBOSE" == true ]]; then
      __commonrc_apprise INFO "Created $commonrc_file ."
    fi
  fi
}

commonrc::_find_regex() {
  local _file="$1"
  local _expr="$2"
  [[ -f "$commonrc_file" ]] && ! grep --extended-regexp "$_expr" "$_file"
  return $?
}

commonrc::_insert_line() {
  local _file _line _regex _match
  _file="$1"
  _line="$2"
  _regex="${3:-"^$_line$"}"
  _match=$(commonrc::_find_regex "$_file" "$_regex") || return $?
  if [[ -n "$_match" ]]; then
    if [[ "$COMMONRC_VERBOSE" == true ]]; then
      apprise INFO "Found line(s): '$_match'."
    fi
  else
    printf '\n%s\n' "$_line" >> "$commonrc_file"
    if [[ "$COMMONRC_VERBOSE" == true ]]; then
      apprise DEBUG "Wrote line: '$_line'."
    fi
  fi
}

commonrc::add_line() {
  # Appends a line to ~/.commonrc if no match is found.
  # Usage:
  #   commonrc::add_line <line> [<regex>]
  # Arguments:
  #   <line>  The full line to add
  #   <regex> A partial-line regex pattern (default: `^<line>$`)
  # Example:
  #   commonrc::add_line "export JAVA_HOME=/opt/jdk21"
  # Notes:
  #   Blank lines are added above and below to avoid any visual grouping with other code.
  commonrc::_insert_line "$commonrc_file" "$1" "$2"
}

commonrc::prepend_to_path() {
  # Adds the first element in $1 that exists to PATH, if no matching line is found.
  # The line is in the form `PATH=$PATH:${1[first-that-exists]}`.
  # Searches for a non-indented line starting with `PATH="`, `export PATH="`, or `declare -x PATH="`,
  # and contains `$1[i]` enclosed by `:` (or at the start and/or end).
  # Usage:
  #   commonrc::prepend_to_path <path ...>
  # Example:
  #   commonrc::prepend_to_path /opt/jdk23/bin /opt/jdk22/bin /opt/jdk21/bin
  # Notes:
  #   Blank lines are added above and below to avoid any visual grouping with other code.
  #   The presence of `:$PATH` in the matched line is NOT checked.
  #   Examples of lines NOT found:
  #     - `[[ -e /opt/tool/bin ]] && PATH="/opt/tool/bin:$PATH"` (not at column 0)
  #     - `PATH=/usr/bin:$PATH` (missing "")
  #.    - `PATH="/usr/bin":"$/usr/local/bin":"$PATH"` (weird use of "")
  local _line _regex
  for _path in "$@"; do
    if [[ -e "$_path" ]]; then
      # shellcheck disable=SC2016
      _line=$(printf 'PATH="%s:$PATH"' "$1")
      _regex=$(printf '^(export |declare -x )?PATH="([^:"]+:)*%s(:[^:"]+)*"' "$_line")
      commonrc::add_line "$_line" "$_regex" \
        && return 0
    fi
  done
  if [[ "$COMMONRC_VERBOSE" == true ]]; then
    __commonrc_apprise ERROR "$(printf 'No paths in (%s) exist.' "$@")"
  else
    __commonrc_apprise ERROR 'No paths in the input list exist.'
  fi
  return 1
}

commonrc::source_from() {
  # Idempotently appends `source $HOME/.commonrc` to the supplied ~/.*rc file.
  # Example: `commonrc::add_to_rc ~/.bashrc ~/.zshrc (or .bashrc .zshrc)`
  local _rc_file="$1"
  if [[ "$_rc_file" != /* && "$_rc_file" != ~/* ]]; then
    _rc_file="$HOME"/."${_rc_file#.}"
  fi
  # shellcheck disable=SC2016
  commonrc::_insert_line "$_rc_file" 'source "$HOME/.commonrc"'
}
