#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

declare -r -A styles=(
  ["0"]="Reset" ["1"]="Bold" ["2"]="Dim" ["3"]="Italic" ["4"]="Underline"
  ["5"]="Blink" ["7"]="Reverse" ["8"]="Hidden" ["9"]="Strikethrough"
)

declare -r -A foreground_colors=(
  ["30"]="Black" ["31"]="Red" ["32"]="Green" ["33"]="Yellow" ["34"]="Blue"
  ["35"]="Magenta" ["36"]="Cyan" ["37"]="White" ["90"]="Bright Black"
  ["91"]="Bright Red" ["92"]="Bright Green" ["93"]="Bright Yellow"
  ["94"]="Bright Blue" ["95"]="Bright Magenta" ["96"]="Bright Cyan" ["97"]="Bright White"
)

declare -r -A background_colors=(
  ["40"]="Black" ["41"]="Red" ["42"]="Green" ["43"]="Yellow" ["44"]="Blue"
  ["45"]="Magenta" ["46"]="Cyan" ["47"]="White" ["100"]="Bright Black"
  ["101"]="Bright Red" ["102"]="Bright Green" ["103"]="Bright Yellow"
  ["104"]="Bright Blue" ["105"]="Bright Magenta" ["106"]="Bright Cyan" ["107"]="Bright White"
)

ansi::table() {
  local code name
  local -n list="$1"
  printf '\n## %s\n\n' "${1/_/ }"
  printf '| code | name           | sequence | sample |\n'
  printf '| ---- | -------------- | -------- | ------ |\n'
  for code in "${!list[@]}"; do
    name="${list[$code]}"
    printf '| %4i | %-14s | %-8s | %b text \e[0m |\n' "$code" "$name" "\e[${code}m" "\e[${code}m"
  done
}

ansi::table "styles"
ansi::table "foreground_colors"
ansi::table "background_colors"

printf '\n## usage\n\n'
printf 'Use semicolons to separate multiple codes in a single escape sequence.\n'
printf 'For example, use \\e[0;1;31m for \e[0;1;31mbold red text\e[0m: '
printf '0 for reset, 1 for bold, and 31 for red.\n'
printf 'Starting with 0 to reset any previously applied color or style is often useful.\n'
printf 'Here, it ensures the text is not italic (etc.) and uses the default background color.\n'
