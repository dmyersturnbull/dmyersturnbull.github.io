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
# Logging
declare use_color=auto
declare -i log_level=2

# Define usage, help info, etc.

declare -r description="\
Description:
  Exports all the data in a database as one .sql.zst file per table.
  Binary fields are hex-encoded.
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
      --color         Whether to use ANSI color and style codes in logs (auto|true|false; default: auto).
  -v  --verbose       Decrement log level threshold, repeatable (default level: INFO).
  -q  --quiet         Increment log level threshold, repeatable (default level: INFO).

Environment variables:
  DB_USER             Username (default: empty).
  DB_PASSWORD         Password (default: empty).
"

declare -r help=""

# Set up logging.

opt_apprise="${APPRISE_SCRIPT:-$HOME/.local/bin/apprise.sh}"
if [[ -f "$opt_apprise" ]]; then
  # shellcheck disable=SC1090
  source "$opt_apprise"
  apprise() {
    apprise::log "$1" "$2"
  }
else
  apprise() {
    printf >&2 "[%s] %s\n" "$1" "$2"
  }
  apprise WARN "File '$opt_apprise' was not found."
  unset opt_apprise
fi

usage_error() {
  apprise ERROR "${1-}"
  printf >&2 '%s\n' "$usage"
  exit 2
}

# Parse args.

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
    --dir=*)
      backup_dir="${1#--dir=}"
      ;;
    -d | --dir)
      backup_dir="$2"
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
      port=$(("${1#--port=}")) || usage_error "Invalid port"
      ;;
    -p | --port)
      port=$(("$2")) || usage_error "Invalid port"
      shift
      ;;
    --zstd-level=*)
      zstd_threads=$(("${1#--zstd-level=}"))
      ;;
    --zstd-level)
      zstd_level=$(("$2"))
      shift
      ;;
    --zstd-threads=*)
      zstd_threads=$(("${1#--zstd-threads=}"))
      ;;
    --zstd-threads)
      zstd_threads=$(("$2"))
      shift
      ;;
    --log-level=*)
      log_level="${1#--log-level=}"
      ;;
    --log-level)
      log_level="$1"
      ;;
    -v | --verbose)
      log_level=$((log_level - 1))
      ;;
    -q | --quiet)
      log_level=$((log_level + 1))
      ;;
    --color=*)
      use_color="${1#--color=}"
      ;;
    --color)
      use_color="$2"
      shift
      ;;
    --*)
      usage_error "Unknown option: '$1'."
      ;;
    *)
      if [[ -v db ]]; then
        usage_error "Unexpected positional argument: '$1'."
      fi
      if [[ -z "$1" ]]; then
        usage_error "DB value must be non-empty."
      fi
      db="$1"
      ;;
  esac
  shift
done

if [[ -v db ]]; then
  usage_error "Missing required positional argument 'db'."
fi
if [[ -v opt_apprise ]]; then
  apprise::config "$log_level" "$use_color" || exit $?
fi

protocol_arg=
socket_arg=
host_arg=
port_arg=
user_arg=
password_arg=
if [[ -n "$socket_path" ]]; then
  protocol_arg=--protocol=socket
  socket_arg=--socket=$socket_path
else
  host_arg=--host=127.0.0.1
  port_arg=--port=$port
  if [[ -v DB_USER ]]; then
    user_arg=--user="$DB_USER"
  fi
  if [[ -v DB_PASSWORD ]]; then
    password_arg=--password="$DB_PASSWORD"
  fi
fi

tables=$(
  mysql \
    "$protocol_arg" \
    "$socket_arg" \
    "$host_arg" \
    "$port_arg" \
    "$user_arg" \
    "$password_arg" \
    --skip-column-names \
    --batch \
    --disable-auto-rehash \
    --database="$db" \
    --execute='show tables' \
)

n_tables=$(($(wc -w <<< "$tables")))
apprise INFO "Backing up $n_tables tables to '$backup_dir'."
apprise INFO "Tables: [ $tables ]."
mkdir -p "$backup_dir"
dt=$(date +%Y-%m-%dT%H%M%S%z)

for table in $tables; do
  table_path=$backup_dir/$db/$table.sql.zst
  error_log=$db-bak-$dt-$table.log
  apprise INFO "Writing table $table..."
  apprise DEBUG "Writing $table to '$table_path' with error log '$error_log'."
  mysqldump \
    "$protocol_arg" \
    "$socket_arg" \
    "$host_arg" \
    "$port_arg" \
    "$user_arg" \
    "$password_arg" \
    --single-transaction \
    --hex-blob \
    --log-error "$error_log"
  "$db" \
    "$table" \
    | zstd -z "-$zstd_level" "--threads=$zstd_threads" > "$table_path" \
    || exit $?
  apprise INFO "Wrote table $table."
  n_lines=$(wc -l <<< "$error_log")
  if ((n_lines > 0)); then
    apprise WARN "$n_lines errors were written to '$error_log'."
    while IFS= read -r line; do
      apprise WARN "$line"
    done < "$error_log"
  fi
done

apprise INFO "Finished backing up $n_tables tables to '$backup_dir'."
