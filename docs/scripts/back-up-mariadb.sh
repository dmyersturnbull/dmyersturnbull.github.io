#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}")" || exit $?
declare -r script_name="${script_path##*/}"
declare -r script_vr=v0.1.0

# Declare options with their defaults.
dt=$(date +%Y-%m-%dT%H%M%S%z)
declare use_timestamp=false
declare backup_root=/bak/mariadb/
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
  -d, --dir           Backup directory <dir> in <dir>/<db-name>/<table-name>.sql.zst (default: $backup_root).
  -t, --timestamp     Use <dir>/<db-name>/<timestamp>/<table-name>.sql.zst instead.
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
      backup_root="${1#--dir=}"
      ;;
    -d | --dir)
      backup_root="$2"
      shift
      ;;
    --timestamp=*)
      _ut="${1#--timestamp=}"
      if [[ "$_ut" =~ ^(0|false|no|n)$ ]]; then
        use_timestamp=false
      elif [[ "$_ut" =~ ^(1|true|yes|y)$ ]]; then
        use_timestamp=true
      else
        usage_error "Invalid value in $1; must be 0|false|no|n or 1|true|yes|y"
      fi
      ;;
    -t | --timestamp)
      use_timestamp=true
      ;;
    --no-timestamp)
      use_timestamp=false
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
      zstd_level=$(("${1#--zstd-level=}"))
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
      log_level="$2"
      shift
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

if [[ ! -v db ]]; then
  usage_error "Missing required positional argument 'db'."
fi
if [[ -v opt_apprise ]]; then
  apprise::config "$log_level" "$use_color" || exit $?
fi

connection_args=()
if [[ -n "$socket_path" ]]; then
  connection_args+=(
    --protocol=socket
    "--socket=$socket_path"
  )
else
  connection_args+=(
    --host=127.0.0.1
    "--port=$port"
  )
fi
[[ -v DB_USER ]] && connection_args+=("--user=$DB_USER")
[[ -v DB_PASSWORD ]] && connection_args+=("--password=$DB_PASSWORD")

mapfile -t tables < <(
  mysql \
    "${connection_args[@]}" \
    --skip-column-names \
    --batch \
    --disable-auto-rehash \
    --database="$db" \
    --execute='show tables' \
)

n_tables=${#tables[@]}
if [[ "$use_timestamp" == true ]]; then
  backup_dir="$backup_root/$db/$dt"
else
  backup_dir="$backup_root/$db"
fi
mkdir -p "$backup_dir"
apprise INFO "Backing up $n_tables tables to '$backup_dir'."
apprise INFO "Tables: [ ${tables[*]} ]."

for table in "${tables[@]}"; do
  table_path="$backup_dir/$table.sql.zst"
  table_part_path="$table_path.part"
  error_log="$db-bak-$dt-$table.log"
  error_log_part="$db-bak-$dt-$table.log.part"
  apprise INFO "Writing table $table..."
  apprise DEBUG "Writing $table to '$table_path' with error log '$error_log'."
  mysqldump \
    "${connection_args[@]}" \
    --single-transaction \
    --hex-blob \
    --log-error="$error_log_part" \
    -- \
    "$db" \
    "$table" \
  | zstd -z "-$zstd_level" "--threads=$zstd_threads" \
  > "$table_part_path" \
  || exit $?
  mv -- "$table_part_path" "$table_path"
  apprise INFO "Wrote table $table."
  if [[ -f "$error_log_part" ]]; then
    n_lines=$(wc -l < "$error_log_part")
    if ((n_lines > 0)); then
      apprise WARN "$n_lines errors were written to '$error_log_part'."
      while IFS= read -r line; do
        apprise WARN "$line"
      done < "$error_log_part"
    fi
    zstd -z "-$zstd_level" "--threads=$zstd_threads" "$error_log_part" -o "$error_log" \
    && rm -- "$error_log_part"
  else
    apprise INFO "No error log file was written."
  fi
done

apprise INFO "Finished backing up $n_tables tables to '$backup_dir'."
