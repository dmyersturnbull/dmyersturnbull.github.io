#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0
#
# Modified from https://serverfault.com/questions/3743/what-useful-things-can-one-add-to-ones-bashrc

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

# Define usage, help description, etc.

declare -r description="\
Description:
  Extracts most archive types.
  Cross-platform but subject to the availability of programs on PATH.
"

declare -r usage="\
Usage:
  $script_name --help
  $script_name <file>

Arguments:
  <file>    Input archive file
"

declare -r help="\
Recognized formats:
  | Filename Extensions  | Format Description                   |
  |----------------------|--------------------------------------|
  | tar.bz2, tbz2        | bzip2 compressed tar archive         |
  | tar.gz, tgz          | gzip compressed tar archive          |
  | tar.xz, txz          | xz compressed tar archive            |
  | tar.lz, tlz          | lzip compressed tar archive          |
  | tar                  | tar archive                          |
  | bz2                  | bzip2 compressed file                |
  | gz                   | gzip compressed file                 |
  | xz                   | xz compressed file                   |
  | lz4                  | lz4 compressed file                  |
  | lzma                 | lzma compressed file                 |
  | lzip                 | lzip compressed file                 |
  | rar                  | RAR archive                          |
  | zip                  | ZIP archive                          |
  | Z                    | legacy UNIX compress archive         |
  | snappy, sz           | snappy compressed file               |
  | brotli, br           | brotli compressed file               |
  | zstd, zst            | zstd compressed file                 |
  | 7z                   | 7-Zip archive                        |
  | rpm                  | RPM package (uses rpm2cpio and cpio) |
  | deb                  | Debian package (uses ar)             |
  | cab                  | CAB archive (uses cabextract)        |
  | lha, lzh             | LHA archive (uses lha)               |
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

# Show help if requested.
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  printf '%s\n%s\n%s\n' "$description" "$usage" "$help"
  exit 0
fi

# Parse arguments.
if (($# != 1)); then
  usage_error "Invalid number of arguments."
fi

file="$1"

case "$file" in
  # Tar archives
  *.tar.bz2 | *.tbz2)
    tar xvjf "$file" || exit $?
    ;;
  *.tar.gz | *.tgz)
    tar xvzf "$file" || exit $?
    ;;
  *.tar.xz | *.txz)
    tar xvJf "$file" || exit $?
    ;;
  *.tar.lz | *.tlz)
    # GNU tar supports the --lzip option for lzip-compressed tar archives.
    tar --lzip -xvf "$file" || exit $?
    ;;
  *.tar.Z)
    tar xvf "$file" || exit $?
    ;;
  *.tar)
    tar xvf "$file" || exit $?
    ;;
  # Single-file compression formats
  *.bz2)
    bunzip2 "$file" || exit $?
    ;;
  *.gz)
    gunzip "$file" || exit $?
    ;;
  *.xz)
    unxz "$file" || exit $?
    ;;
  *.lz4)
    unlz4 "$file" || exit $?
    ;;
  *.lzma)
    unlzma "$file" || exit $?
    ;;
  *.lzip)
    lzip -d "$file" || exit $?
    ;;

  # Other archive formats
  *.rar)
    unrar x "$file" || exit $?
    ;;
  *.zip)
    unzip "$file" || exit $?
    ;;
  *.Z)
    uncompress "$file" || exit $?
    ;;
  *.snappy | *.sz)
    snunzip "$file" || exit $?
    ;;
  *.brotli | *.br)
    brotli -d "$file" || exit $?
    ;;
  *.zstd | *.zst)
    unzstd "$file" || exit $?
    ;;
  *.7z)
    7z x "$file" || exit $?
    ;;
  *.rpm)
    rpm2cpio "$file" | cpio -idmv || exit $?
    ;;
  *.deb)
    ar x "$file" || exit $?
    ;;
  *.cab)
    cabextract "$file" || exit $?
    ;;
  *.lha | *.lzh)
    lha x "$file" || exit $?
    ;;
  *)
    general_error "Unknown file type: $file"
    ;;
esac
