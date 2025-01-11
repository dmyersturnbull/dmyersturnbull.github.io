#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
# SPDX-FileCopyrightText: Copyright 2024, Contributors to the dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: MIT

commonrc::initialize() {
  # Creates a ~/.commonrc if it doesn't already exist.
  # The mostly blank file just adds these directories to $PATH:
  # /usr/sbin, /usr/local/sbin, and ~/bin (creating ~/bin if needed)
  mkdir -p "$HOME/bin"
  if [[ ! -e ~/.commonrc ]]; then
    # shellcheck disable=SC2016
    printf '%s\n\n%s\n%s\n%s\n' \
      '# Common file sourced by ~/.bashrc, ~/.zshrc, etc.' \
      '# Configure $PATH' \
      'EXPORT PATH' \
      'PATH="$PATH:/usr/sbin:/usr/local/sbin:$HOME/bin"'
  fi
}

commonrc::_insert_line() {
  local _file="$1"
  local _line="$2"
  [[ -f "$_file" ]] \
    && ! grep --quiet --fixed-strings --line-regexp "$_line" "$_file" \
    && printf '\n%s\n' "$_line" >> "$_file"
}

commonrc::add_line() {
  # Appends a line to ~/.commonrc if it does not already exist.
  # Technically, appends '\n<line>\n'.
  # (The first \n avoids visual grouping with any preceding block.)
  # Example: commonrc::add_line "export JAVA_HOME=/opt/jdk21"
  commonrc::_insert_line ~/.commonrc "$1"
}

commonrc::add_to_rc() {
  # Idempotently appends \n+'source ~/.commonrc'+\n to the supplied ~/.*rc file.
  # Example: commonrc::add_to_rc ~/.bashrc ~/.zshrc (or .bashrc .zshrc)
  local _rc_file="$1"
  [[ "$_rc_file" != /* && "$_rc_file" != ~/* ]] \
    && _rc_file="$HOME/.${_rc_file#.}"
  commonrc::_insert_line "$_rc_file" 'source ~/.commonrc'
}
