#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024–2026, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

# How to use:
# ```
# declare use_color=auto
# declare -i log_level=2
#
# source "$HOME/.local/bin/apprise.sh"
#
# while (($# > 0)); do
#   case "$1" in
#     --)             break ;;
#     -v | --verbose) log_level=$((log_level - 1)) ;;
#     -q | --quiet)   log_level=$((log_level + 1)) ;;
#     --color)        use_color=yes ;;
#     --no-color)     use_color=no ;;
#   esac
# done
#
# apprise::config $log_level "$use_color" || exit $?
#
# apprise::error "An error"
# apprise::warn "A warning"
# apprise::info "An info message"
# apprise::debug "A debug message"
# apprise::log INFO "another info message"
#
# # To modify the styles:
# apprise::define_styles '\e[2m' '' '\e[1m' '\e[1;31m'
#
# # To modify the levels:
# apprise::define_levels OK SCARY
# apprise::define_styles '' '\e[1;31m' # normal -> bold+red
# ```

# Key mutable state:
declare -i apprise_level=2 # INFO
declare apprise_use_color=false # Whether to actually use color (i.e., not `auto`).

# Additional mutable state (initialized at bottom):
declare -A apprise_levels=() # Maps names and numbers to numbers.
declare -A apprise_names=()  # Maps names and numbers to names.
declare -A styles=()         # Maps names to ANSI escape sequences.

##### Functions to define styles and levels #####

# Defines a new ordered list of levels and names (in order of lowest to highest level).
# Completely replaces any previous list (even if the new list is shorter).
# Note that passing no arguments will cause every `apprise::log` call to fail.
# This function does not affect the mapping of level names to styles.
# To set styles for your new names, call `apprise::define_styles` AFTER.
# Args:
#   $@: array of level names, from lowest to highest level
# Examples:
#   `apprise::define_levels TRACE INFO FAIL`
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

# Clears the map of level names to styles.
# You likely don't need this function; `apprise::define_styles` is usually sufficient.
apprise::clear_styles() {
  declare -g -A styles=()
}

# Defines styles for the levels (in order of lowest to highest).
# Important: Styles are tied to level names, not indices.
# If you want to change the list of levels or their names,
# call `apprise::define_levels` first, before setting the styles.
# Args:
#    $@: array of ANSI escape sequence, from lowest to highest level (may pass fewer)
# Examples:
#   `apprise::define_styles '\e[0;2m' '' '\e[0;1;31m'`
# Technical note:
#   Previous name->style associations are not removed.
#   Therefore, this will use the default style for INFO:
#   ```
#   apprise::define_levels OK FAULT
#   apprise::define_levels DEBUG INFO WARN ERROR
#   apprise::info "still works"
#   ```
apprise::define_styles() {
  local style name
  local -i num=1
  for style in "$@"; do
    name=${apprise_names[$num]}
    styles[$name]=$style
    num=$((num + 1))
  done
}

##### Logging functions #####

# Logs at level `$1` if it is at least the current level.
# Args:
#   $1: level name or number (normally 1 thru 4)
#   $2: message string
# Steams:
#   stderr: the formatted message, if $1 is ≥ `apprise_level`
apprise::log() {
  local name=${apprise_names[$1]}
  local level=${apprise_levels[$1]}
  local message=$2
  local style="${styles[$name]:-}"
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

# Parses a level name or number.
# You likely don't need this function; see `apprise::config` instead.
# Args:
#   $1: a level name or number (normally 1 thru 4)
# Returns:
#   0: normally
#   2: if the level is not recognized
# Streams:
#   stdout: the number of the matching level
#   stderr: an ERROR-level message if returning 2
apprise::parse_level() {
  if ! echo "${apprise_levels[$1]}"; then
    apprise::log_max "Invalid log level '$1'." || return $?
    return 2
  fi
}

# Parses a `--color` arg, writing `auto`, `true`, or `false`.
# You likely don't need this function; see `apprise::config` instead.
# Args:
#   $1: either `auto`, `1`/`true`/`yes/`on`, or `0`/`false`/`no`/`off`
# Returns:
#   0: normally
#   2: if the string is not recognized
# Streams:
#   stdout: `auto`, `true`, or `false`
#   stderr: an ERROR-level message if returning 2
apprise::parse_use_color() {
  local v="$1"
  if [[ "$v" =~ ^(1|true|yes|on)$ ]]; then
    echo true
  elif [[ "$v" =~ ^(0|false|no|off)$ ]]; then
    echo false
  elif [[ "$v" == auto ]]; then
    echo auto
  else
    apprise::log_max "Invalid log color option '$v'." || return $?
    return 2
  fi
}

# Writes `true` or `false` per `$1`, `$NO_COLOR`, `$FORCE_COLOR`, and TTY status.
# This is only called by `apprise::config`; see it for more info.
apprise::_config_use_color() {
  local v
  v="$(apprise::parse_use_color "$1")" || return $?
  if [[ "$v" =~ ^(true|false)$ ]]; then
    echo "$v"
  elif [[ -n "$NO_COLOR" ]]; then
    echo false
  elif [[ -n "$FORCE_COLOR" ]]; then
    echo true
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

# Sets the current level and color preference.
# If `$2` is `auto`, checks for these env vars:
#   - `$NO_COLOR`     https://no-color.org/
#   - `$FORCE_COLOR`  https://force-color.org/
# If both are nonempty, `$NO_COLOR` takes precedence.
# Args:
#   $1: level name or index (normally 0 thru 4)
#   $2: `auto`, `1`/`true`/`yes/`on`, or `0`/`false`/`no`/`off`
# Env vars:
#   `$NO_COLOR`: true if nonempty
#   `$FORCE_COLOR`: true if nonempty
# Returns:
#   0: normally
#   2: if `$1` is out of range or `$2` is not recognized
# Streams:
#   stderr: an ERROR-level message if returning 2
apprise::config() {
  apprise_level=$(apprise::_config_level "$1") || return $?
  apprise_use_color="$(apprise::_config_use_color "$2")" || return $?
}

##### Defaults #####

# Resets the levels (but not styles).
# The current level and color preference are not affected.
apprise::reset_levels() {
  apprise::define_levels DEBUG INFO WARN ERROR
}

# Resets the levels and styles.
# The current level and color preference are not affected.
apprise::reset() {
  apprise::reset_levels
  # Equivalent to `apprise::define_styles "${DEBUG_COLOR:-'\e[0;2m'}"`, ...
  declare -g -A styles=(
    [DEBUG]="${APPRISE_DEBUG_COLOR:-'\e[0;2m'}"    # dim
    [INFO]="${APPRISE_INFO_COLOR:-'\e[0;1;2m'}"    # dim bold
    [WARN]="${APPRISE_WARN_COLOR:-'\e[0;31m'}"     # plain red
    [ERROR]="${APPRISE_ERROR_COLOR:-'\e[0;1;31m'}" # bold red
  )
}

apprise::reset
