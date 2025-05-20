# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

# How to use:
# 1.  Source this file.
# 2a. Declare `log_level=1`. Increment for every `-q` and decrement for every `v` (−∞ to +∞).
# 2b. Declare `use_color=auto`, then replace with any `--color` option value.
# 3.  Call `apprise::config <log_level> <use_color`.
# 4.  Call `apprise::log` to log.
# S1: To modify the colors/styles, call `apprise::define_styles`.
# S2: To modify level names, call `apprise::define_levels`, then `apprise::define_styles`.

declare -r -i apprise_default_level=2 # INFO

# Key mutable state:
declare -i apprise_level=$apprise_default_level
declare apprise_use_color=false # Whether to actually use color (i.e., not `auto`).

# Additional mutable state (initialized at bottom):
declare -A apprise_levels=() # Maps names and numbers to numbers.
declare -A apprise_names=()  # Maps names and numbers to names.
declare -A styles=()         # Maps names to ANSI escape sequences.

# Define a new ordered list of levels with the provided names, from lowest to highest.
# Passing no arguments will cause every call to `apprise::log` to fail.
# Example: `apprise::define_levels TRACE INFO FAIL`.
# See also: `apprise::define_styles`.
apprise::define_levels() {
  declare -g -A apprise_levels=()
  declare -g -A apprise_names=()
  local name
  local -i num=1
  for name in "$@"; do
    apprise_levels[$num]=$num
    apprise_levels[$name]=$num
    apprise_names[$num]=$name
    apprise_names[$name]=$name
  done
}

# Clear all styles and colors (probably not needed).
# Use `apprise::define_styles` to set new ones.
apprise:clear_styles() {
  declare -g -A styles=()
}

# Defines styles for each of the level names, in order from lowest to highest.
# Example: `apprise::define_levels '\e[0;2m' '' '\e[0;1;31m'`.
# See also: `apprise::define_levels`.
apprise::define_styles() {
  # Previous styles are not removed.
  local style, name
  local -i num=1
  for style in "$@"; do
    name=${apprise_names[$num]}
    styles[$name]=$style
    ((num++))
  done
}

# Writes a log at level $1, if $1 is ≥ `apprise_level`.
# Usage: `apprise::log <name|number> <msg>`.
# Example: `apprise::log ERROR Failed.`
apprise::log() {
  local name=${apprise_names[${1,,}]}
  local level=${apprise_levels[${1,,}]}
  local message=$2
  local style="${styles[$level]}"
  ((level < apprise_level)) && return
  if [[ $apprise_use_color == true ]]; then
    printf >&2 "%b[%s] %s\e[0m\n" "$style" "$name" "$message"
  else
    printf >&2 "[%s] %s\n" "$name" "$message"
  fi
}

# Calls `apprise::log` at level 1 (normally DEBUG).
apprise::debug() {
  apprise::log 1 "$1" || return $?
}

# Calls `apprise::log` at level 2 (normally INFO).
apprise::info() {
  apprise::log 2 "$1" || return $?
}

# Calls `apprise::log` at level 3 (normally WARN).
apprise::warn() {
  apprise::log 3 "$1" || return $?
}

# Calls `apprise::log` at level 4 (normally ERROR).
apprise::error() {
  apprise::log 4 "$1" || return $?
}

# Writes a message at the highest level (normally ERROR), then exits.
# Usage: `apprise::exit <exit code> <msg>`.
apprise::exit() {
  local -i code=$1
  local msg=$2
  apprise::log ${#apprise_levels[@]} "$msg" || true
  exit $code
}

# Sets the current log level, clamping the numeric level `$1`.
apprise::set_level() {
  n=${#apprise_levels[@]}
  apprise_level=$(($1 < 1 ? 1 : ($1 > n ? n : $1)))
}

# Sets whether to use color from `$1` (either `auto`, `true/yes`, or `false/no`).
apprise::set_use_color() {
  local v="$1"
  if [[ "$v" == auto ]]; then
    apprise_use_color=$([[ -t 2 ]] || echo true || echo false)
  elif [[ "$v" =~ true|yes ]]; then
    apprise_use_color=true
  elif [[ "$v" =~ false|no ]]; then
    apprise_use_color=false
  else
    apprise::log ERROR "Invalid --color value; must be auto, true/yes, or false/no (got: '$v')."
    return 2
  fi
}

# Sets the current log level and color option.
# Usage: `apprise::config <level number> <auto|true/yes|false/no>`.
apprise::config() {
  apprise::set_level "${1:-$apprise_level}"
  apprise::set_use_color "${2:-$apprise_use_color}"
}

# Resets the levels and styles (but not the current level or color option).
apprise::reset() {
  apprise::define_levels DEBUG INFO WARN ERROR
  # Equivalent to apprise::define_styles "${DEBUG_COLOR:-'\e[0;2m'}", ...
  declare -g -A styles=(
    [DEBUG]="${DEBUG_COLOR:-'\e[0;2m'}"    # dim
    [INFO]="${INFO_COLOR:-'\e[0;1;2m'}"    # dim bold
    [WARN]="${WARN_COLOR:-'\e[0;31m'}"     # plain red
    [ERROR]="${ERROR_COLOR:-'\e[0;1;31m'}" # bold red
  )
}

apprise::reset
