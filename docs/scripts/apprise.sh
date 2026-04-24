#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

# How to use:
# 1.  Source this file.
# 2a. Declare `log_level=1`.
#     - Increment for every `-q` and decrement for every `v` (−∞ to +∞).
#     - Optionally, set `log_level` with any `--log-level` option value.
# 2b. Declare `use_color=auto`.
#     - Replace with any `--color` option value.
# 3.  Call `apprise::config <log_level> <use_color>`.
# 4.  Call `apprise::log` to log.
# S1: To modify the colors/styles, call `apprise::define_styles`.
# S2: To modify level names, call `apprise::define_levels`, then `apprise::define_styles`.

# Key mutable state:
declare -i apprise_level=2 # INFO
declare apprise_use_color=false # Whether to actually use color (i.e., not `auto`).

# Additional mutable state (initialized at bottom):
declare -A apprise_levels=() # Maps names and numbers to numbers.
declare -A apprise_names=()  # Maps names and numbers to names.
declare -A styles=()         # Maps names to ANSI escape sequences.

##### Functions to define styles and levels #####

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
apprise::clear_styles() {
  declare -g -A styles=()
}

# Defines styles for each of the level names, in order from lowest to highest.
# Example: `apprise::define_levels '\e[0;2m' '' '\e[0;1;31m'`.
# See also: `apprise::define_levels`.
apprise::define_styles() {
  # Previous styles are not removed.
  local style name
  local -i num=1
  for style in "$@"; do
    name=${apprise_names[$num]}
    styles[$name]=$style
    num=$((num + 1))
  done
}

##### Logging functions #####

# Writes a log at level $1, if $1 is ≥ `apprise_level`.
# Usage: `apprise::log <name|number> <msg>`.
# Example: `apprise::log ERROR Failed.`
apprise::log() {
  local name=${apprise_names[$1]}
  local level=${apprise_levels[$1]}
  local message=$2
  local style="${styles[$name]}"
  if ((level < apprise_level)); then
    return
  fi
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

# Calls `apprise::log` at the highest configured level (normally ERROR).
apprise::max() {
  apprise::log ${#apprise_levels[@]} "$1" || return $?
}

##### Functions that parse args #####

apprise::parse_level() {
  if ! echo "${apprise_levels[$1]}"; then
    apprise::log_max "Invalid log level '$1'." || return $?
    return 2
  fi
}

# Parses the `--color` arg `$1` to 'auto', 'true', or 'false'.
# `$1` must be `auto`, `true`|`yes`|`on`, or `false|no|off`.
# Returns: 0 normally; 2 if `$1` is invalid.
# STDERR: An ERROR-level log message if `$1` is invalid.
apprise::parse_use_color() {
  local v="$1"
  if [[ "$v" =~ ^(true|yes|on)$ ]]; then
    echo true
  elif [[ "$v" =~ ^(false|no|off)$ ]]; then
    echo false
  elif [[ "$v" == auto ]]; then
    echo auto
  else
    apprise::log_max "Invalid log color option '$v'." || return $?
    return 2
  fi
}

# Writes either 'true' or 'false' based on `$1` and the env vars `NO_COLOR` and `FORCE_COLOR`.
# `$1` should be the string passed to e.g. `--color`.
# Returns: 0 normally; 2 if `$1` is invalid.
# STDERR: An ERROR-level log message if `$1` is invalid.
apprise::_config_use_color() {
  local v
  v="$(apprise::parse_use_color "$1")" || return $?
  if [[ "${FORCE_COLOR:-}" == 1 ]]; then
    echo true
  elif [[ "${NO_COLOR:-}" == 1 ]]; then
    echo false
  elif [[ "$v" == auto ]] && [[ -t 2 ]]; then
    echo true
  elif [[ "$v" == auto ]]; then
    echo false
  else
    echo "$v"
  fi
}

# Clamps the numeric level `$1` (writes the clamped number to stdout).
apprise::_config_level() {
  local -i n max
  if ! n=${apprise_levels[$1]}; then
    apprise::log_max "Invalid log level '$1'." || return $?
    return 2
  fi
  max=${#apprise_levels[@]}
  echo $((n < 1 ? 1 : (n > max ? max : n)))
}

# Sets the current log level and color option.
# Usage: `apprise::config <level number> <auto|true/yes/on|false/no/off>.
apprise::config() {
  apprise_level=$(apprise::_config_level "$1") || return $?
  apprise_use_color="$(apprise::_config_use_color "$2")" || return $?
}

##### Defaults #####

# Resets the levels and styles (but not the current level or color option).
apprise::reset() {
  apprise::define_levels DEBUG INFO WARN ERROR
  # Equivalent to apprise::define_styles "${DEBUG_COLOR:-'\e[0;2m'}", ...
  declare -g -A styles=(
    [DEBUG]="${APPRISE_DEBUG_COLOR:-'\e[0;2m'}"    # dim
    [INFO]="${APPRISE_INFO_COLOR:-'\e[0;1;2m'}"    # dim bold
    [WARN]="${APPRISE_WARN_COLOR:-'\e[0;31m'}"     # plain red
    [ERROR]="${APPRISE_ERROR_COLOR:-'\e[0;1;31m'}" # bold red
  )
}

apprise::reset
