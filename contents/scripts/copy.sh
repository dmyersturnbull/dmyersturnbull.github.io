#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

declare -r description="\
Description:
  Uses rsync to copy recursively while preserving attributes (except owner).
  Symlinks are copied as-is, without dereferencing.\
"

declare -r usage="\
Usage:
  $script_name --help
  $script_name [extra rsync options] <source-path> <target-path>\
"

declare -r help="\
Options passed to rsync:
  | Option                 | Description                                                           |
  |------------------------|-----------------------------------------------------------------------|
  | --recursive            | Recursively copy directories and their contents.                      |
  | --links                | Preserve symbolic links as they are (do not follow them).             |
  | --preserve-permissions | Preserve file permissions.                                            |
  | --group                | Preserve group ownership (for groups that the user belongs to).       |
  | --times                | Preserve modification times.                                          |
  | --crtimes              | Preserve creation times (if supported by the filesystem).             |
  | --atimes               | Preserve access times (if supported by the filesystem).               |
  | --open-noatime         | Open files without updating their access times (where supported).     |
  | --xattrs               | Preserve xattrs (if supported by the filesystem).                     |
  | --acls                 | Preserve access control lists (if supported by the filesystem).       |
  | --compress-choice=zstd | If using compression, prefer Zstandard for lower memory usage.        |
  | --no-motd              | No message of the day.                                                |
  | --info=progress2       | Show overall progress during transfer, not per file.                  |
  | --human-readable (x3)  | Display file sizes in units of 1024.                                  |

Potentially useful options:
  | Option                 | Description                                                           |
  |------------------------|-----------------------------------------------------------------------|
  | --compress             | Enable compression during transfer.                                   |
  | --human-readable (x3)  | Display file sizes in units of 1024.                                  |
  | --safe-links           | Don't create symlinks that point outside the destination directory.   |\
"

apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

usage_error() {
  apprise ERROR "$1" || true
  printf >&2 '%s\n' "$usage" || true
  exit 2
}

if (($# == 1)) && [[ "$1" == "--help" || "$1" == "-h" ]]; then
  printf '%s\n%s\n%s\n' "$description" "$usage" "$help"
fi
if (($# < 2)); then
  usage_error "Incorrect usage."
fi

rsync \
  --recursive \
  --links \
  --preserve-permissions \
  --group \
  --times \
  --crtimes \
  --atimes \
  --open-noatime \
  --acls \
  --xattrs \
  --compress-choice=zstd \
  --info=progress2 \
  --human-readable \
  --human-readable \
  --human-readable \
  "$@" \
  || exit $?
