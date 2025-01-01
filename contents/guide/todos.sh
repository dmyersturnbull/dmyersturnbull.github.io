#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to the dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: MIT
set -o errexit -o nounset -o pipefail

# Function to search for T/O/D/O comments (without the /)

__z=$(basename "$0")
declare -r prog_name=$__z
declare -r prog_vr=v0.1

# arguments
dir=.
files='*.*'
todo='TODO[: ]|FIXME[: ]'
recurse=false
regex=auto
declare -i wide=0

# usage, help info, etc.
declare -r usage="
Usage:
  $prog_name [-R,--recursive] [-d,--dir=<directory>] [-f,--files=<glob>] [-t,--todo=<text>] [--regex] [--literal] [-w,--wide ...]
  $prog_name -h --help
  $prog_name --version

Options:
  -R, --recursive   Search subdirectories, except those matching '.*' or '*~' (default: false)
  -d, --dir=<path>    Search directory (default: '$dir')
  -f, --files=<glob>  Glob to match filenames (default: '$files')
  -t, --todo=<text>   String(s) to search for in files (default: '$todo')
  --regex             Interpret <text> as a regular expression (ERE) (default: $regex)
  --literal           Interpret <text> as a literal (default: $regex)
  -w, --wide          Widen the columns; can pass multiple times (default: $wide).
                      Column widths for --wide passed <n> times are
                      File path: 30/60/90/120/120/...; Line: 4/4/6/8/8/...; Comment:  60×2^(<n>+1)
"
declare -r example="Example: $prog_name --dir src/ --files '*.java' --todo FIXME:"
declare -r info="\
Finds 'TODO' in files.

Reads text files (per --dir and --files), finding strings like TODO or FIXME (per --todo and --regex). \
Files and directories beginning with '.' or ending with '~' are always ignored.

Writes a Markdown table that looks like this, with one line per TODO:

| File path                    | Line | Comment                                                      |
------------------------------ | ---- | ------------------------------------------------------------ |
| util/CalculatorImpl.java     | 1182 | This is a hack.                                              |

The 'Comment' is the text following the TODO/FIXME and any ':' or whitespace). \
If it exceeds the length determined by --wide, it is truncated with '...' appended. \
'File path' and 'Line' are never truncated; the columns will simply be misaligned if necessary. \
Note: If there are multiple TODOs on one line, only the first is shown.\
"

while (( $# > 0 ));  do
  case "$1" in
    --glob=*)        files="${1#--files=}"                                           ;;
    -g|--glob)       files="$2"                                             ; shift  ;;
    --dir=*)         dir="${1#--dir=}"                                               ;;
    -d|--dir)        dir="$2"                                               ; shift  ;;
    --todo=*)        todo="${1#--todo=}"                                             ;;
    -t|--todo)       todo="$2"                                              ; shift  ;;
    -w|--wide)       wide=$((wide + 1))                                     ; shift  ;;
    --regex)         regex=true                                                      ;;
    --literal)       regex=false                                                     ;;
    -R|--recursive)  recurse=true                                                    ;;
    -h|--help)       printf '%s %s\n\n%s\n\n%s\n\n%s\n' \
                       "$prog_name" "$prog_vr" "$info" "$usage" "$example"  ; exit 0 ;;
    -v|--version)    printf '%s\n' "$prog_vr"                               ; exit 0 ;;
    --)                                                                       break  ;;
    *)               >&2 printf "Unknown option: '%s'\n%s\n" "$1" "$usage"  ; exit 2 ;;
  esac
  shift
done

# $recurse --> --directories <recurse|skip>
declare -s dir_mode
[[ "$recurse" == true ]] && dir_mode=recurse || dir_mode=skip

# $regex --> --extended-regexp|--fixed-strings
declare -s style
if [[ "$regex" == auto ]]; then
  [[ "$todo" == *'|'* ]] && style=extended-regexp || style=fixed-strings
elif [[ "$regex" == true ]]; then
  style=extended-regexp
elif [[ "$regex" == false ]]; then
  style=fixed-strings
fi

# --wide
# widths are:  min(120, C1 * (wide+1)) | min(8, 2*floor((wide+4)/2) | C3 * 2**(wide+1)
#              ^                         ^                            ^
#              File path                 Line number                  Comment
# total line widths are:
#   wide=0:  30 + 3 + 4 + 3 +   60 = 100
#   wide=1:  60 + 3 + 4 + 3 +  120 = 190
#   wide=2:  90 + 3 + 6 + 3 +  240 = 342
#   wide=3: 120 + 3 + 8 + 3 +  480 = 614
#   wide=4: 120 + 3 + 8 + 3 +  960 = 1094
#   ...
_col1_width=$(( 30 * (wide+1) ))
_col2_width=$(( wide < 4 ? 2 * ((wide+4)/2) : 8 ))
_col3_width=$(( 60 * 2**(wide+1) ))

# Start the Markdown table
# We'll pass $format to awk so we get nicely aligned columns
# https://stackoverflow.com/questions/4409399/padding-characters-in-printf
_bar="$( printf '%0.1s' "-"{1..10000} )"
format="%-${_col1_width}s | %-${_col2_width}s | %-${_col3_width}s\n"
# shellcheck disable=SC2059
printf '%s%s | %s | %s |\n' \
  "$( printf "$format" "File Path" Line Comment )" \
  "${_bar:${_col1_width}}" \
  "${_bar:${_col2_width}}" \
  "${_bar:${_col3_width}}"

# Use grep to find and pipe to awk
grep \
  --directories "$dir_mode" \
  --binary-files=without-match \
  --include="$files" \
  --line-number \
  --exclude-dir '.*' \
  --exclude '.*' \
  --exclude-dir '*~' \
  --exclude '*~' \
  "--$style" \
  "$todo" \
  "$dir" \
  | awk -F: -v format="$format" -v todo="$todo" -v col3_width="$_col3_width" '
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
      printf format, $1, $2, comment;
    }
'
exit $?
