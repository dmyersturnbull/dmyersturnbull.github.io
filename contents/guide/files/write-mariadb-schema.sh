#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
# SPDX-FileCopyrightText: Copyright 2024, Contributors to the dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: MIT

_usage="Usage: $0"

if (($# == 1)) && [[ "$1" == "--help" ]]; then
  printf >&2 '%s\n' "$_usage"
  printf >&2 "Dumps the schema to schema.sql.\n"
  printf >&2 "Requires environment vars DB_NAME, DB_USER, and DB_PASSWORD\n"
  exit 0
fi

if (($# > 0)); then
  printf >&2 '%s\n' "$_usage"
  exit 2
fi

db_name_="$DB_NAME"
if [[ -v "$DB_SOCKET" ]]; then
  db_socket_="$DB_SOCKET"
else
  db_socket_=
  db_port_=3306
  db_user_="$DB_USER"
  db_password_="$DB_PASSWORD"
fi
out_file="schema-$db_name_.sql"

if [[ -z "$db_socket_" ]]; then
  mysqldump \
    --protocol=socket \
    --socket="$db_socket_" \
    --skip-add-drop-table \
    --single-transaction \
    --no-data \
    "$db_name_" \
    > "$out_file"
else
  mysqldump \
    --host=127.0.0.1 \
    --port="$db_port_" \
    --user="$db_user_" \
    --password="$db_password_" \
    --skip-add-drop-table \
    --single-transaction \
    --no-data \
    "$db_name_" \
    > "$out_file"
fi

# remove the auto_increment -- we don't care
sed -r -i -e 's/auto_increment=[0-9]+ //g' "$out_file"
printf >&2 "Wrote to '%s'\n" "$out_file"
