#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

declare -r description="\
Description:
  Uses rsync to create a backup that hardlinks to the previous backup.
  Symlinks are copied as-is, without dereferencing.
  Requires BTRFS and must be run as root.
"

declare -r usage="\
Usage:
  $script_name --help
  $script_name <source-dir> <target-root>

Arguments:
  source-dir          What directory to back up (required).
  target-root         Directory in a separate filesystem to store source-dir backups (required).

Environment variables:
  TEMP_SUBVOL_ROOT    Where to store temporary BTRFS snapshot subvolumes (default: uses mktemp).
                      WARNING: Subvolumes added here are not cleared on error.
"

declare -r help=""

apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

usage_error() {
  apprise ERROR "$1" || true
  printf >&2 '%s\n' "$usage" || true
  exit 2
}

general_error() {
  apprise ERROR "$1" || true
  exit 1
}

if (($# == 1)) && [[ "$1" == "--help" || "$1" == "-h" ]]; then
  printf '%s\n%s\n%s\n' "$description" "$usage" "$help"
  exit 2
fi
if (($# != 2)) || [[ "$1" =~ \w* || "$2" =~ \w* ]]; then
  usage_error "Incorrect usage: missing positional arguments."
fi
if [[ "$1" =~ \w* || "$2" =~ \w* ]]; then
  usage_error "Incorrect usage: arguments must be non-empty and non-blank."
fi
if [[ "$USER" != root ]]; then
  general_error "Must be run as root."
fi
if ! btrfs help > /dev/null; then
  general_error "Command 'btrfs' not found or not usable."
fi

if [[ -n "$TEMP_SUBVOL_ROOT" ]]; then
  snapshots_root="$TEMP_SUBVOL_ROOT"
else
  snapshots_root=$(mktemp -d -p "")
fi

create_backup::run() {
  local source_dir="$1"
  local target_root="$2"
  local last
  last=$(
    find "$target_root" \
      -maxdepth 1 \
      -type d \
      -regextype posix-extended \
      -regex '.*/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' \
      -printf '%P\n' \
      | sort -r \
      | head -n1 \
      || true
  )
  dt=$(date -u +%Y-%m-%dT%H:%M:%SZ) || return $?
  apprise DEBUG "Timestamp is '$dt'."
  snap_dir="$snapshots_root"/$dt
  apprise DEBUG "Making snapshot dir '$snap_dir'."
  sudo mkdir -p "$(dirname -- "$snap_dir" || return $?)" || return $?
  target_dir="$target_root"/"$dt"
  apprise INFO "Will create backup in '$target_dir'."
  if [[ -n "$last" ]]; then
    local link_dest_arg=--link-dest="$last"
    apprise INFO "Referencing previous backup at '$last'."
  else
    local link_dest_arg=
    apprise WARN "Found no previous backups under '$target_root'."
  fi
  mkdir "$target_dir" || return $?
  # make a readonly (-r) btrfs snapshot to avoid corruption if a file is modified during backup.
  apprise INFO "Creating btrfs readonly snapshot at '$snap_dir'."
  btrfs subvolume snapshot -r -- "$source_dir" "$snap_dir" || return $?
  apprise INFO "Starting rsync..."
  rsync \
    "$link_dest_arg" \
    --hard-links \
    --delay-delete \
    --recursive \
    --owner \
    --group \
    --devices \
    --perms \
    --specials \
    --acls \
    --xattrs \
    --links \
    --times \
    --crtimes \
    --atimes \
    --open-noatime \
    --compress \
    --compress-choice=zstd \
    --verbose \
    --info=progress2 \
    --human-readable \
    --human-readable \
    --human-readable \
    "$snap_dir" \
    "$target_dir"
  rt=$?
  if ! $rt; then
    apprise ERROR "rsync failed."
    apprise WARN "The snapshot $snap_dir still exists. To delete it, use 'btrfs subvolume delete'."
    return $rt
  fi
  apprise INFO "Finished rsync."
  apprise INFO "Deleting btrfs snapshot '$snap_dir'."
  btrfs subvolume delete "$snap_dir" || return $?
}

create_backup::run "$1" "$2" || exit $?
apprise INFO "Done."
