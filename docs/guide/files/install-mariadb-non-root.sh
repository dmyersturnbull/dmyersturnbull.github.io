#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

if [[ "$(uname)" != Linux ]]; then
  printf "[ERROR] %s only supports Linux, not %s.\n" "$script_name" "$(uname)"
  exit 3
fi

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

# usage, help description, etc.

description="\
Description:
  Installs and configures MariaDB without root access.
"

declare -r usage="\
Usage:
  $script_name --help
  $script_name [OPTIONS] <file>

Arguments:
  <file>       Path to a mariadb.tar.gz file containing a MariaDB binary distribution.

Options:
  -h, --help   Show this message and exit.
  -t, --to     Target directory to install to (default: ~/mysql/).

Example:
  $script_name --to ~/mysql/ mariadb-11.7.1-linux-systemd-x86_64.tar.gz
"

apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

usage_error() {
  apprise ERROR "$1"
  printf >&2 '%s\n' "$usage"
  exit 2
}

general_error() {
  apprise ERROR "$1"
  exit 1
}

# Parse arguments.

to="$HOME/mysql/"
gz_file=

while (($# > 0)); do
  case "$1" in
    --)
      break
      ;;
    -h | --help)
      printf '%s\n\n%s\n' "$description" "$usage"
      exit 0
      ;;
    --to=*)
      to="${1#--to=}"
      ;;
    -t | --to)
      to="$2"
      shift
      ;;
    -*)
      usage_error "Unrecognized option: '$1'."
      ;;
    *)
      # Positional arg for input .gz file.
      # If it's already set, then this is an extra positional arg (which is an error).
      if [[ "$gz_file" ]]; then
        usage_error "Unexpected positional argument: '$1'."
      fi
      gz_file="$1"
      ;;
  esac
  shift
done

if [[ -z "$gz_file" ]]; then
  usage_error "Missing required positional argument <file>."
fi
if [[ "$gz_file" != *.tar.gz ]]; then
  general_error "Input file must be a .tar.gz file: '$1'."
fi
if [[ ! -f "$gz_file" ]]; then
  general_error "Input file does not exist or is not a file: '$gz_file'."
fi
if [[ -e "$to" ]]; then
  general_error "Target directory exists and is not a directory: '$to'."
fi

if [[ -d "$to" ]] && [[ -n "$(ls -A "$to")" ]]; then
  general_error "Target directory is not empty: '%s'." "$to"
fi

# Extract the .tar.gz to the target dir (~/mysql/).
mkdir -p "$to"
gunzip -s "$gz_file" | tar -C "$to" -x -f - || exit $?

# Create a defaults file.
config_file="$to/my.cnf"
touch -a "$config_file"

# Install MariaDB.
install_script="$to/scripts/mariadb-install-db"
chmod +x "$install_script" || exit $?
"$install_script" --defaults-file="$config_file" || exit $?

# Declare a specific, local socket named "socket".
socket_file="$to/socket"
cat >> "$config_file" << EOF
[client]
socket = $socket_file

[mysqld]
socket = $socket_file
EOF

bin_dir="$to/bin/"
apprise INFO "Installed MariaDB to $to with defaults file $$config_file."
apprise INFO "Start the server daemon by running '$bin_dir/mysqld_safe'."
apprise INFO "Connect through local socket $socket_file by running '$bin_dir/mysql'."
apprise INFO "Consider adding $bin_dir to your PATH."
