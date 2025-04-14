# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

# Source this file.

declare -r -A log_styles=(
  [DEBUG]="${DEBUG_COLOR:-'\e[0;2m'}"    # dim
  [INFO]="${INFO_COLOR:-'\e[0;1;2m'}"    # dim bold
  [WARN]="${WARN_COLOR:-'\e[0;31m'}"     # plain red
  [ERROR]="${ERROR_COLOR:-'\e[0;1;31m'}" # bold red
)

declare -r -A log_levels=(
  [DEBUG]=1
  [INFO]=2
  [WARN]=3
  [ERROR]=4
  [1]=1
  [2]=2
  [3]=3
  [4]=4
)

apprise::log() {
  local min_level=$1
  local level=$2
  local message=$3
  local color="${log_styles[$level]}"
  ((${log_levels[$level]} < min_level)) && return
  if [[ -t 2 ]] && [[ -n "$color" ]]; then
    printf >&2 "%s[%s] %s\e[0m\n" "$color" "$level" "$message"
  else
    printf >&2 "[%s] %s\n" "$level" "$message"
  fi
}

apprise::process_log_args() {
  local v
  v=$((2 + $1 - $2))
  v=$((v < 1 ? 1 : v))
  v=$((v > 4 ? 4 : v))
  echo $v
}

apprise::process_color_arg() {
  local v="$1"
  if [[ "$v" == auto ]] && [[ -t 2 ]]; then
    echo true
  elif [[ "$v" == auto ]]; then
    echo false
  elif [[ "$v" == true || "$v" == yes ]]; then
    echo true
  elif [[ "$v" == false || "$v" == no ]]; then
    echo true
  else
    apprise ERROR "Invalid --color value; must be auto|true|yes|false|no (got: '$v')."
    return 2
  fi
}
