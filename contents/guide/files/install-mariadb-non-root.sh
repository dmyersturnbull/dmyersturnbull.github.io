#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
# SPDX-FileCopyrightText: Copyright 2024, Contributors to the dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: MIT

__z=$(basename "$0")
declare -r prog_name=$__z
declare -r prog_vr=v0.1.0

# usage, help info, etc.
declare -r usage="\
Usage:
  $prog_name [-t,--to=<path>] <file>
  $prog_name -h --help
  $prog_name --version

Options:
  -t, --to=<dir>  Target directory to install to (default: ~/mysql/).

Arguments:
  <file> Path to a mariadb.tar.gz file containing a MariaDB binary distribution.

Example:
  $prog_name --to ~/mysql/ mariadb-11.7.1-linux-systemd-x86_64.tar.gz
"
info="\
$prog_name $prog_vr

Installs and configures MariaDB without root access.
"

# Arguments and options:
target_dir=
gz_file=

# Function to set <file>
# It's positional, so treat any subsequent positional args as unknown.
_mariadb_non_root::set_gz_file() {
  if [[ -n "$gz_file" ]]; then
    printf >&2 'Unknown arg: '%s'\n%s\n' "$1" "$usage"
    exit 2
  fi
  gz_file="$1"
}

while (($# > 0)); do
  case "$1" in
    --to=*) target_dir="${1#--to=}" ;;
    -t | --to) target_dir="$2" shift ;;
    -h | --help)
      printf '%s\n\n%s\n' "$info" "$usage"
      exit 0
      ;;
    -v | --version)
      printf '%s\n' "$prog_vr"
      exit 0
      ;;
    --) break ;;
    -*)
      printf >&2 "Unknown option: '%s'\n%s\n" "$1" "$usage"
      break
      ;;
    *) _mariadb_non_root::set_gz_file "$1" ;;
  esac
  shift
done

if [[ ! -f "$gz_file" ]]; then
  printf >&2 "Path does not exist or is not a file: '%s\n'" "$gz_file"
  exit 3
fi

if [[ ! -d "$gz_file" ]] || [[ -d "$gz_file" ]] && [[ -n "$(ls -A "$gz_file")" ]]; then
  printf >&2 "Target path already exists (and is nonempty or not a directory): '%s\n'" "$target_dir"
  exit 3
fi

# Extract the .tar.gz to the target dir (~/mysql/).
mkdir -p "$target_dir"
gunzip -s "$gz_file" | tar -C "$target_dir" -x -f - || exit $?

# Create a defaults file.
config_file="$target_dir/my.cnf"
touch -a "$config_file"

# Install MariaDB.
install_script="$target_dir/scripts/mariadb-install-db"
chmod +x "$install_script" || exit $?
"$install_script" --defaults-file="$config_file" || exit $?

# Declare a specific, local socket named "socket".
socket_file="$target_dir/socket"
cat >> "$config_file" <<- EOF
[mysqld]
socket = $socket_file
[mysql]
socket = $socket_file
EOF

bin_dir="$target_dir/bin/"
printf >&2 'Installed MariaDB to %s with defaults file %s .\n' "$target_dir" "$config_file"
printf >&2 'Start the server daemon by running %s .\n' "$bin_dir/mysqld_safe"
printf >&2 'Connect through local socket %s by running %s.\n' "$socket_file" "$bin_dir/mysql"
printf >&2 'Consider adding %s to your PATH.\n' "$bin_dir"
