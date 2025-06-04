#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"
declare -r script_vr=v0.2.0

# Declare options with their defaults.
declare dir=.
declare files='*.*'
declare todo='(TODO|FIXME)([^A-Za-z0-9_]|$)'
declare recurse=false
declare regex=auto
declare -i log_level=2
declare -i width=0

# Define usage, help info, etc.

declare -r description="\
Description:
  Reads text files (per --dir and --files), finding strings like TODO or FIXME (per --todo).
"

declare -r usage="\
Usage:
  $script_name --help
  $script_name --version
  $script_name [OPTIONS]

Options:
  -h, --help       Show this message and exit.
      --version    Show the version string and exit.
  -R, --recursive  Search subdirectories, except those matching '.*' or '*~' (default: false)
  -d, --dir        Search directory (default: '$dir')
  -f, --files      Glob to match filenames (default: '$files')
  -t, --todo       String(s) to search for in files (default: '$todo')
      --regex      Interpret <text> as a regular expression (ERE) (default: $regex)
      --literal    Interpret <text> as a literal (default: $regex)
  -w, --widen      Widen the columns; can pass multiple times (default: $width).
                   Column widths for --widen passed <n> times are
                   File path: 30/60/90/120/120/...; Line: 4/4/6/8/8/...; Comment:  60×2^(<n>+1)
  -v  --verbose    Decrement log level threshold, repeatable (default level: INFO).
  -q  --quiet      Increment log level threshold, repeatable (default level: INFO).

Examples:
  $script_name -R -d src/main/java/ -f '*.java'
    Searches in all .java files under 'src/main/java' and its subdirectories.

  $script_name --todo 'TO-FIX:|HACK:' -f '*.py'
    Searches for 'TO-FIX:' and 'HACK:' in .py files in the current directory.

  $script_name --todo '**FIX**' --literal
    Searches for '**FIX** as a literal string.
"

declare -r help="\
Notes:

  Requirements:
    Requires GNU awk. \
    On macOS, you may need to install via it via Brew and set 'alias awk=gawk'.

  File globs:

    The value of --files is passed to grep --include. \
    Files and directories beginning with '.' or ending with '~' are always ignored (via --exclude).

  Table format:

    Writes a Markdown table that looks like this, with one line per TODO:

    | File path                    | Line | Comment                                                      |
    ------------------------------ | ---- | ------------------------------------------------------------ |
    | util/CalculatorImpl.java     | 1182 | This is a hack.                                              |

    The 'Comment' is the text following the TODO/FIXME and any ':' or whitespace). \
    If it exceeds the length determined by --widen, it is truncated with '...' appended. \
    'File path' and 'Line' are never truncated; the columns will simply be misaligned if necessary. \
    Note: If there are multiple TODOs on one line, only the first is shown.\

  Column widths:

    Where n is the number of times \`--widen\` is passed, column widths are:

    | File path          | Line                    | Comment        |
    | ------------------ | ----------------------- | -------------- |
    | min(120, 30×(n+1)) | min(8, 2×floor((n+4)/2) | 60×2^(n+1) - 2 |

    Adding 10 characters for the borders (2×2 for edges plus 3×2 between columns):

    | n   | Path   | Line | Comment | Total |
    | --- | ------ | ---- | ------- | ----- |
    | 0   | +  30  | + 4  |  + 56   |  100  |
    | 1   | +  60  | + 4  | + 116   |  180  |
    | 2   | +  90  | + 6  | + 238   |  344  |
    | 3   | + 120  | + 8  | + 478   |  616  |
    | 4   | + 120  | + 8  | + 958   | 1096  |
    | 5   | + 120  | + 8  | + ...   | ...   |
"

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
    --glob=*)
      files="${1#--files=}"
      ;;
    -g | --glob)
      files="$2"
      shift
      ;;
    --dir=*)
      dir="${1#--dir=}"
      ;;
    -d | --dir)
      dir="$2"
      shift
      ;;
    --todo=*)
      todo="${1#--todo=}"
      ;;
    -t | --todo)
      todo="$2"
      shift
      ;;
    -w | --widen)
      width=$((width + 1))
      shift
      ;;
    --regex)
      regex=true
      ;;
    --literal)
      regex=false
      ;;
    -R | --recursive)
      recurse=true
      ;;
    -v | --verbose)
      log_level=$((log_level-1))
      ;;
    -q | --quiet)
      log_level=$((log_level+1))
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
      usage_error "Unexpected positional argument: '$1'."
      ;;
  esac
  shift
done

apprise::config $log_level "$use_color" || exit $?

# $recurse --> --directories <recurse|skip>
if [[ "$recurse" == true ]]; then
  declare -r dir_mode=recurse
else
  declare -r dir_mode=skip
fi

# $regex --> --extended-regexp|--fixed-strings
if [[ "$regex" == auto && "$todo" == *'|'* ]]; then
  declare -r style=extended-regexp
elif [[ "$regex" == auto ]]; then
  declare -r style=fixed-strings
elif [[ "$regex" == true ]]; then
  declare -r style=extended-regexp
elif [[ "$regex" == false ]]; then
  declare -r style=fixed-strings
fi

# --wide
# The help string explains this.
declare -r _col1_width _col2_width _col3_width
_col1_width=$((30 * (width + 1)))
_col2_width=$((width < 4 ? 2 * ((width + 4) / 2) : 8))
_col3_width=$((60 * 2 ** (width + 1) - 2))

# Start the Markdown table.
# We'll pass $format to awk so we get nicely aligned columns.
# https://stackoverflow.com/q/4409399
_bar="$(printf '%0.1s' "-"{1..10000})"
col_format="%-${_col1_width}s | %-${_col2_width}s | %-${_col3_width}s\n"
# shellcheck disable=SC2059
printf '%s%s | %s | %s |\n' \
  "$(printf "$col_format" "File Path" Line Comment)" \
  "${_bar:${_col1_width}}" \
  "${_bar:${_col2_width}}" \
  "${_bar:${_col3_width}}" \
  || exit $?

# Use grep to find and pipe to awk
grep \
  --directories "$dir_mode" \
  --binary-files without-match \
  --include "$files" \
  --line-number \
  --exclude-dir '.*' \
  --exclude '.*' \
  --exclude-dir '*~' \
  --exclude '*~' \
  "--$style" \
  -- \
  "$todo" \
  "$dir" \
  | awk \
    -F: \
    -v col_format="$col_format" \
    -v todo="$todo" \
    -v col3_width="$_col3_width" \
    '
    {
      # Example line that grep writes:
      #   src/main.cpp:1428: int main() { // TO-DO: stub
      #               ^    ^
      # So, split by `:` via `-F:` -- $1 := src/main.cpp and $2 := 1428
      comment = substr($0, index($0, $3));
      # Strip the prefix `T/O/D/O`, an optional `:`, and any whitespace
      sub("^[ \t]*(?:" todo "):?[ \t]*", "", comment);
      if (length(comment) > col3_width) {
        comment = substr(comment, 1, col3_width - 3) "..."
      }
      printf col_format, $1, $2, comment;
    }
'
exit $?
