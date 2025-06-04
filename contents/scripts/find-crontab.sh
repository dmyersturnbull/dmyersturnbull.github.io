#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

# List of known crontab system paths
crontab_system_paths=(
  "/etc/crontab" # file
  "/etc/cron.d/"
  "/etc/cron.hourly/"
  "/etc/cron.daily/"
  "/etc/cron.weekly/"
  "/etc/cron.monthly/"
)
# List of known crontab user directories
crontab_user_dirs=(
  # on Linux
  "/var/spool/cron/crontabs/"
  "/var/spool/cron/"
  # on macOS and BSD
  "/var/at/tabs/"
  "/var/cron/tabs/"
  "/private/var/at/tabs/"
  "/private/var/cron/tabs/"
)

find_user_dir() {
  local -i n_found=0
  local last_found=
  for path in "${crontab_user_dirs[@]}"; do
    if [[ -d "$path" ]]; then
      apprise INFO "Found user directory: '$path'."
      n_found=$((n_found+1))
      last_found="$path"
    fi
  done
  if ((n_found == 1)); then
    printf '%s\n' "$last_found"
  elif ((n_found > 1)); then
    apprise WARN "$n_found user directories found."
  elif ((n_found == 0)); then
    apprise INFO "No user directory found."
  fi
  ((n_found > 0)) && return 0 || return 1
}

find_user_file() {
  local -i n_found=0
  local last_found=
  for path in "${crontab_user_dirs[@]}"; do
    file="$path/$USER"
    if [[ -f "$file" ]]; then
      apprise INFO "Found user crontab: '$file'."
      n_found=$((n_found+1))
      last_found="$file"
    fi
  done
  if ((n_found == 1)); then
    printf '%s\n' "$last_found"
  elif ((n_found > 1)); then
    apprise WARN "$n_found user crontabs found."
  else
    apprise INFO "User crontab not found."
  fi
  ((n_found == 1)) && return 0 || return 1
}

found_file=$(find_user_file)
if $?; then
  # Write found_file to stdout.
  # If stdout and stderr are mixed, format as:
  # \n                       <-- err
  # <<<                      <-- err
  #    /private/var/at/tabs/ <-- out
  # >>>                      <-- err
  printf >&2 '\n<<<\n   '
  printf '%s\n' "$found_file"
  printf >&2 '>>>\n'
else
  find_user_dir > /dev/null || true # ignore dir written to stdout
  exit 1
fi
