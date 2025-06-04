#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"
declare -r script_vr=v0.1.0

# Declare options with their defaults.
declare backup_dir=/bak/mariadb/
declare -i port=3306
declare socket_path=
# 2 is a little faster than the default of 3 (range 1 to 19)
# Using >1 thread for compression is probably just a waste.
declare -i zstd_level=2
declare -i zstd_threads=1
declare -i log_level=2

# Define usage, help info, etc.

declare -r description="\
Description:
  Exports all the data in a database as one .sql.zst file per table.
  Binary fields are hex-encoded.\
"

declare -r usage="\
Usage:
  $script_name --help
  $script_name --version
  $script_name [--port=<number>] [OPTIONS] <db-name>
  $script_name  --socket=<path>  [OPTIONS] <db-name>

Arguments:
  <db-name>           Database name.

Options:
  -h, --help          Show this message and exit.
      --version       Show the version string and exit.
  -d, --dir           Backup directory <dir> in <dir>/<db-name>/<table-name>.sql.zst (default: $backup_dir).
  -s, --socket        Path to a Unix socket file for connection.
  -p, --port          TCP port for connection (default: $port).
      --zstd-level    ZSTD compression level; higher is slower (default: $zstd_level).
      --zstd-threads  Number of threads for ZSTD to use (default: $zstd_threads).
  -v  --verbose       Decrement log level threshold, repeatable (default level: INFO).
  -q  --quiet         Increment log level threshold, repeatable (default level: INFO).

Environment variables:
  DB_USER             Username (default: empty).
  DB_PASSWORD         Password (default: empty).\
"
declare -r help=""

# Set up logging.

if [[ -f "$HOME"/bin/apprise.sh ]]; then
  source "$HOME"/bin/apprise.sh
  apprise() {
    apprise::log "$1" "$2"
  }
else
  apprise() {
    printf >&2 "[%s] %s\n" "$1" "$2"
  }
fi

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

while (($# > 0)); do
  case "$1" in
    --)
      break
      ;;
    -h | --help)
      printf '%s %s\n' "$script_name" "$script_vr"
      printf '%s\n%s\n%s\n' "$description" "$usage" "$help"
      exit 0
      ;;
    --version)
      printf '%s\n' "$script_vr"
      exit 0
      ;;
    --to=*)
      out_file="${1#--to=}"
      ;;
    -t | --to)
      out_file="$2"
      shift
      ;;
    --socket=*)
      socket_path="${1#--socket=}"
      ;;
    -s | --socket)
      socket_path="$2"
      shift
      ;;
    --port=*)
      port="${1#--port=}"
      ;;
    -p | --port)
      port="$2"
      shift
      ;;
    --zstd-level=*)
      zstd_threads="${1#--zstd-level=}"
      ;;
    --zstd-level)
      zstd_level="$2"
      shift
      ;;
    --zstd-threads=*)
      zstd_threads="${1#--zstd-threads=}"
      ;;
    --zstd-threads)
      zstd_threads="$2"
      shift
      ;;
    -v | --verbose)
      n_verbose=$((n_verbose + 1))
      ;;
    -q | --quiet)
      n_quiet=$((n_quiet + 1))
      ;;
    --color=*)
      use_color="${1#--color=}"
      ;;
    --color)
      use_color="$2"
      shift
      ;;
    --*)
      usage_error "Unrecognized option: '$1'."
      ;;
    *)
      if [[ -n "$db" ]]; then
        usage_error "Unexpected positional argument: '$1'."
      fi
      db="$1"
      ;;
  esac
  shift
done

apprise::config $log_level "$use_color" || exit $?

declare protocol_arg socket_arg host_arg port_arg user_arg password_arg
if [[ -n "$socket_path" ]]; then
  protocol_arg=--protocol=socket
  socket_arg=--socket=$socket_path
else
  host_arg=--host=127.0.0.1
  port_arg=--port=$port
  if [[ -n "$DB_USER" ]]; then
    user_arg=--user=$DB_USER
  fi
  if [[ -n "$DB_PASSWORD" ]]; then
    password_arg=--password=$DB_PASSWORD
  fi
fi

out_file="$db-schema.sql"
dt=$(date +%Y-%m-%dT%H:%M:%S%z)
error_log=$db-schema-$dt.log

mysqldump \
  "$protocol_arg" \
  "$socket_arg" \
  "$host_arg" \
  "$port_arg" \
  "$user_arg" \
  "$password_arg" \
  --skip-add-drop-table \
  --skip-comments \
  --create-options \
  --single-transaction \
  --no-data \
  --log-error "$error_log"
"$db" \
  > "$out_file"

n_lines=$(wc -l <<< "$error_log")
if ((n_lines > 0)); then
  apprise WARN "$n_lines errors were written to '$error_log'."
  while IFS= read -r line; do
    apprise WARN "$line"
  done < "$error_log"
fi

# Remove `auto_increment` -- we don't care.
sed -E 's/auto_increment=[0-9]+ //g' "$out_file"
apprise INFO "Wrote to '%s'." "$out_file"
