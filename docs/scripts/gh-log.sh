#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

declare -r description="\
Description:
  Prints a colorful, dense, multiline git log with GitHub commit URLs.
"

declare -r usage="
Usage:
  $script_name --help
  $script_name <owner> <repo>

Example:
  $script_name microsoft vscode

Example output:
  <https://github.com/microsoft/vscode/commit/924c6d0f> \
  2024-12-14T18:49:11-05:00  --Kerri Johnson
  fix: correct post-vc delta gen to use upstream v2

  <https://github.com/microsoft/vscode/commit/81c9a34d> \
  2025-01-02T11:15:50+02:00  --John Johnson
  fix: revert change 924c6d0f by Kerri Johnson.
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

if (($# == 1)) && [[ "$1" == --help || "$1" == -h ]]; then
  printf >&2 '%s\n%s\n' "$description" "$usage"
  exit 0
fi
if (($# != 2)); then
  usage_error "Incorrect usage."
fi

declare -r _url="https://github.com/$1/$2/commit"
# shellcheck disable=SC2116
_format=$(
  echo \
    '%C(bold)%C(green)' \
    "<$_url/%h>" \
    '%C(italic)%(decorate:prefix=  ,suffix=,pointer=→)' '%n' \
    '%C(bold)%C(cyan)' \
    '%aI' \
    '%C(italic)  --%an' '%n' \
    '%C(dim)%s' '%n'
)
git log --pretty=tformat:"$_format" || exit $?
