#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
# SPDX-FileCopyrightText: Copyright 2024, Contributors to the dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: MIT

_usage="Usage: $0"

if (($# == 1)) && [[ "$1" == "--help" ]]; then
  printf '%s\n' "$_usage"
  printf "Exports all the data in a database as one .sql.zst file per table.\n"
  printf "Binary fields are hex-encoded.\n"
  printf "Requires environment vars DB_NAME, DB_USER, DB_PASSWORD, DB_PORT, and DB_BACKUP_DIR\n"
  exit 0
fi

if (($# > 1)); then
  printf >&2 '%s\n' "$_usage"
  exit 2
fi

# 2 is a little faster than the default of 3 (range 1 to 19)
# Using >1 thread for compression is probably just a waste.
zstd_level_=2
zstd_threads_=1
if [[ -v "$ZSTD_LEVEL" ]]; then
  zstd_level_=$ZSTD_LEVEL
fi
if [[ -v "$ZSTD_THREADS" ]]; then
  zstd_threads_=$ZSTD_THREADS
fi

db_name_="$DB_NAME"
if [[ -v "$DB_SOCKET" ]]; then
  db_socket_=$DB_SOCKET
else
  db_socket_=
  db_port_=3306
  db_user_=$DB_USER
  db_password_=$DB_PASSWORD
fi

db_backup_dir_="/bak/mariadb/$db_name_"
if [[ -v "$DB_BACKUP_DIR" ]]; then
  db_backup_dir_=$DB_BACKUP_DIR
fi

if [[ -z "$db_socket_" ]]; then
  tables=$(
    mysql \
      --skip-column-names \
      --batch \
      --disable-auto-rehash \
      --protocol=socket \
      --socket="$db_socket_" \
      --database="$db_name_" \
      --execute='show tables'
  )
else
  tables=$(
    mysql \
      --skip-column-names \
      --batch \
      --disable-auto-rehash \
      --port="$db_port_" \
      --user="$db_user_" \
      --password="$db_password_" \
      --database="$db_name_" \
      --execute='show tables'
  )
fi

n_tables=$(($(wc -w <<< "$tables")))
printf 'Backing up %i tables to %s\n' "$n_tables" "$db_backup_dir_"
mkdir -p "$db_backup_dir_"

for table in $tables; do
  table_path="$db_backup_dir_/$table.sql.zst"
  printf >&2 'Writing table %s...\n' "$table"
  # 2147483648 is the max
  if [[ -z "$db_socket_" ]]; then
    mysqldump \
      --protocol=socket \
      --socket="$db_socket_" \
      --single-transaction \
      --hex-blob \
      --max_allowed_packet=2147483648 \
      "$db_name_" \
      "$table" \
      | zstd -z "-$zstd_level_" "--threads=$zstd_threads_" \
        > "$table_path"
  else
    mysqldump \
      --host=127.0.0.1 \
      --port="$db_port_" \
      --user="$db_user_" \
      --password="$db_password_" \
      --single-transaction \
      --hex-blob \
      --max_allowed_packet=2147483648 \
      "$db_name_" \
      "$table" \
      | zstd -z "-$zstd_level_" "--threads=$zstd_threads_" \
        > "$table_path"
  fi
  printf >&2 'Wrote table %s.\n' "$table"
done

printf >&2 'Finished backing up %i tables to %s .\n' "$n_tables" "$db_backup_dir_"
