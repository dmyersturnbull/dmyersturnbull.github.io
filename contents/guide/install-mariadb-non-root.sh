#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
__z=$(basename "$0")
declare -r prog_name=$__z
info="Installs and configures MariaDB without root access."
usage="Usage: $prog_name <version (e.g. 11.4.7)>"

if (( $# == 1 )) && [[ "$1" == "--help" ]]; then
  printf '%s\n%s\n%s\n' "$prog_name" "$info" "$usage"
  exit 0
fi

if (( $# != 1 )); then
  >&2 printf '%s\n' "$usage"
  exit 2
fi

mariadb_vr="$1"
target_dir=~/mysql
config_file="$target_dir/my.cnf"
if [[ -e "$target_dir" ]]; then
  >&2 printf "Error: '%s' already exists.\n" "$target_dir"
  exit 3
fi

# download mariadb
arch=$(uname --machine)
_base_url="https://downloads.mariadb.org"
dir_name="mariadb-$mariadb_vr-linux-$arch"
gz_name="$dir_name.tar.gz"
curl --remote-name --remote-header-name --location \
  "$_base_url/mariadb-$mariadb_vr/bintar-linux-$arch/$gz_name?serve" \
  || exit $?

gunzip --stdout "$gz_name" | tar --extract --file - || exit $?
mv "$dir_name" "$target_dir" || exit $?

# create a defaults file
touch -a "$config_file"

# install MariaDB
install_script="$target_dir/scripts/mariadb-install-db"
chmod +x "$install_script" || exit $?
"$install_script" --defaults-file="$config_file" || exit $?

# declare a specific, local socket
cat >> "$config_file" <<- EOF
[mysqld]
socket = ~/mysql/socket
[mysql]
socket = ~/mysql/socket
EOF
