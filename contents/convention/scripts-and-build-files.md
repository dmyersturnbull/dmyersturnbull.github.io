# Scripts and build files

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Command-line tools

### Standard streams

As long as doing so sensible, CLI tools should read from stdin and write to stdout.
In either cases, they must direct logging messages to stderr, never to stdout.

### Arguments

Distinguish between **optional** arguments (“options” or “switches”) and **required** (positional) arguments.

- Optional arguments MUST be `--named` options using the Linux convention of
  `--` for long names and `-` for short (single-letter) names.
- Required arguments SHOULD be positional unless there are more than 3.

Prefer named options over positional arguments, and limit positional argument lists to ≤ 3 items.
Arbitrary-length lists are fine as long as all positions (1–∞) carry the same meaning.
This table summarizes:

- ✅ `<tool> [<options>]`
- ✅ `<tool> [<options>] <arg-1>`
- ✅ `<tool> [<options>] <arg-1> <arg-2>`
- ✅ `<tool> [<options>] <args...>`
- ❌ `<tool> [<options>] <arg-1> <args...>` (positional and varargs)
- ❌ `<tool> [<options>] <arg-1> <arg-2> <arg-3> <arg-4>` (> 3 positional args)

Allow named options both before and after positional arguments.

Use `-` for single-character (“short”) options and `--` for long ones (e.g. `--user`).
All options should include `--long` names,
but include **short names only for common and non-dangerous options**.
If possible, allow both `--option <arg>` and `--option=<arg>`.

Use standard option names:

- `--help`
- `--version` (output the version to stdout and exit)
- `--verbose` (and optionally `-v`)
- `--quiet` (and optionally `-q`)

## Bash

??? rationale

    1. It’s more portable, and it allows callers to choose the specific Bash.
    2. This allows the script to be used in a pipe.
       (Note: [Shell bulletins use `2`](https://tldp.org/LDP/abs/html/exitcodes.html) to indicate misuse.)
    3. `function my_fn {}` is effectively deprecated, non-portable, and never necessary.
        Note that `function my_fn() {}` is technically invalid in all major shell, though most will tolerate it.
    4. It’s more clear, and it prevents bugs like the one illustrated on the last line below.

### Rules

Follow
[bertvv’s Bash cheat sheet](https://bertvv.github.io/cheat-sheets/Bash.html),
the
[Google shell guide](https://google.github.io/styleguide/shellguide.html),
and this guide’s rules (below).
These three are mostly complimentary, but there are a few contradictions;
this guide’s rules take precedence.

??? info "What are the specific contradictions?"

    - **Prefer `$var` over `${var}`.**
       (bertvv’s cheat sheet mandates `{var}`.)
    - **Use `stderr` for all logging; use stdout only for pipeable output.**
      (The Google guide is unclear on this.)
    - **Choose a max line length**, per your discretion.
      (The Google guide requires ≤80.)
    - **Format function headers (comments) as you see fit.**
      (Google doesn’t specify a format, but the examples use one.)
    - **`TODO: ` is sufficient to indicate a TODO comment**.
      (Google requires `TODO(author):`.)
      An author name is unnecessary, especially if the script is under version control.
      Use `FIXME: ` for things like unfinished or placeholder code.

#### Shebang, header, and `set` options

Start every file like this.
For more on the SPDX headers and why they matter, see the
[“Source Headers” in the maintainer guide](../ref/maintainer-guide.md#source-headers).

```bash
#!/usr/bin/env bash #(1)!
# SPDX-FileCopyrightText: Copyright {date(s)}, Contributors to {project}
# SPDX-PackageHomePage: {https uri}
# SPDX-License-Identifier: {spdx id}

set -o errexit -o nounset -o pipefail # "strict mode"
```

1. Use `/usr/bin/env` to honor the user’s environment.
   `/bin/bash`,`/usr/bin/bash`, and `/usr/local/bin/bash` could all be different.

The `set -o` options are important.
With `IFS=$'\n\t'`, these options are sometimes called
[Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/).
`IFS=$'\n\t'` is omitted here because it can make code brittle.

**Importantly:** When writing your code, pretend these options are not enabled.
This forces you to handle errors explicitly, with proper comments, error codes, and error messages.
It also makes the code more interoperable and shareable.

#### Variables

Use `UPPERCASE_SNAKE_CASE` for environment variables and `lowercase_snake_case` for others.
Prefer `$var`; use `${var}` only when needed.

??? rationale

    I recently (2024-08) changed my mind on `$var` vs. `${var}` per
    [less > more](https://dmyersturnbull.github.io/convention/#principles).
    Decent syntax highlighters already distinguish variables clearly.

#### stdout and stdin

Shell scripts make it easy to chain, piping data from one command to the next without storage IO.
This results in higher throughput, lower latency, less wear on storage devices, lower energy usage, …,
along with easier parallelization and code that’s concise and obvious.

So, default to using stdout and stdin instead of files.
Use stdout only for machine-readable output, **not** logging.

#### stderr

Use stderr for all logging, not just errors.

<b>Note about `--help` and usage errors:</b>
When calling `my-script --help`, the expected output is a usage string,
so it should be written to stdout despite not being very machine-readable.
For usage errors (e.g. `my-script --obviously-invalid-option`), write to stderr instead.

#### Logging format

For longer-running scripts, indicate the level of each logging statement (e.g. `[INFO]`).
Use the levels `DEBUG`, `INFO`, `WARN`, and `ERROR`, with `INFO` as the default level.
Other structured data may be included (e.g. date-time, time elapsed, % progress, thread id).

If desired, you can distinguish logging levels with ANSI color and/or style codes.
This is ok **only** if stderr is a TTY as determined by `[[ -t 2 ]]` or with a `--color` (e.g.) command-line switch.
Terminal color schemes can vary, so prefer fewer colors.
See [`todos.sh`](../scripts/todos.sh) for an example.

??? example "Example log file"

    ```log
    [DEBUG] Init took 6.5 s.
    [INFO]  Locating configuration...
    [WARN]  No configuration found; using defaults.
    [ERROR] The input file is malformatted. Exiting.
    ```

#### Exit codes

`exit 0` for success.
For usage errors, exit with code 2
([like shell bulletins do)](https://tldp.org/LDP/abs/html/exitcodes.html)).
Use 1 for other general errors.
When types of errors need to be distinguished, use codes in the range 3–125.
It may be helpful to reference
[`sysexits.h` in the C standard library](https://manpages.ubuntu.com/manpages/lunar/man3/sysexits.h.3head.html)
(ignoring `EX__BASE` and `EX_USAGE`).

#### Paths

Use the
[XDG Base Directory Standard](https://specifications.freedesktop.org/basedir-spec/latest/),
even on macOS.
For example:

```bash
declare -r config_dir="${XDG_CONFIG_HOME:-$HOME/some-app/}"
mkdir -p -m 0700 "$config_dir"
```

#### Script directory and name

??? rationale

    This is the only reasonable solution that:

    1. Works on both Linux and BSD(/macOS); **and**
    2. works even if the script path
       is relative or absolute;
       is a symlink or contains a symlinked component;
       contains `/../`, `/./`, or `//`;
       was `source`-ed;
       lives inside the current CWD;
       contains a space;
       starts with `-`; or
       whose final component starts with `-`.

    _Note:_
    This even works with paths that contain `[*?]`, [|&<>]`, `['"]`, and even `\\` and possibly control chars.
    However, please, please
    [don’t use such characters in filenames](https://dwheeler.com/essays/fixing-unix-linux-filenames.html).

Rely on `BASH_SOURCE` and
[`realpath`](https://www.gnu.org/software/coreutils/manual/html_node/realpath-invocation.html#realpath-invocation).
Although `realpath` is not POSIX, it is available on all modern Linux and BSD/macOS distributions.

Use the following definitions as needed:

```bash
script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"
declare -r script_dir="${script_path%/*}"
unset script_path
```

!!! warning "Caution: avoid name clashes for `source`-ed scripts"

    If the script is meant to be `source`-ed, choose more specific variable names to avoid clashes.

    Otherwise, if both scripts define `script_name` or `script_dir`,
    you’ll get an error like `read-only variable: script_name`.
    Worse, if only `script_path` is shared:

    ??? example

        ```bash title="functions.sh"
        #!/usr/bin/env bash
        script_path="$( realpath -- "${BASH_SOURCE[0]}" || exit $? )"
        # ...
        ```

        ```bash title="script.sh"
        #!/usr/bin/env bash
        script_path="$( realpath -- "${BASH_SOURCE[0]}" || exit $? )"
        source "${script_path%/*}"/functions.sh
        (( $# > 1)) && printf >&2 'Usage: %s <path>\n' "${script_path##*/}"
        ```

        ```bash title="interactive shell"
        ❯ ./script.sh
        Usage: functions.sh <path>
        ```

Make sure to use `--` with `realpath` to protect paths that start with `-`.
(Don’t use `-e` because it is GNU-specific and not necessary.)
Because `realpath` returns canonical paths, the Bash parameter expansions work perfectly,
and `dirname`/`basename` are not needed.

??? warning "GNU vs. BSD `realpath` in other contexts"

    GNU/Linux and BSD(/macOS) `realpath` differ.
    Most importantly, BSD’s will error if a path component is not found.
    That’s a non-issue here because `${BASH_SOURCE[0]}` must exist,
    but this difference could cause problems elsewhere.

    Pass `-e`/`--canonicalize-missing` to GNU `realpath` to require that components exist.
    Don’t rely on `"$(uname)" == Linux` or `"$OSTYPE" == linux-gnu` because, for example,
    `realpath` might be aliased to Brew coreutils `realpath` on macOS.
    This snippet is a reasonable solution:

    ```bash
    some_path="$1"
    if realpath -e .; then
      some_path="$(realpath -e -- "$some_path" || exit $?)"
    else
      full_path="$(realpath -- "$some_path" || exit $?)"
    fi
    ```

#### Deprecated things

- [Use `printf`, not `echo`](../cheatsheet/bash-tips.md#use-printf-not-echo).
- Use `[[ ]]`, not `[ ]`.
- Use `$( )`, not backticks.
- Use `(( ))` for numeric comparisons.
- Use `[[ -z "$var" ]]` and `[[ -n "$var" ]]` rather than `[[ "$var" == "" ]]` and `[[ "$var != "" ]]`.

#### Formatting

Choose a max line length, per your discretion.
Recommended choices are ≤80, ≤90, and ≤100, but aim for shorter lines (i.e. ≤80) even if the max is higher.

#### Comments

Use comments as needed, not out of habit.
Above non-trivial functions, add a header that lists the arguments, environment variables, return codes, etc.
It’s ok to be brief or to refer to other documentation.

#### TODO and FIXME

Use `TODO: short description` for minor issues,
and `FIXME: short description` for things like unfinished or placeholder code.

### Example

See [`todos.sh`](../scripts/todos.sh) for a more complex example.

```bash
#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to the gamma package
# SPDX-PackageHomePage: https://github.com/the-gamma-people/gamma
# SPDX-License-Identifier: Apache-2.0
set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"
declare -r -i default_retries=2
declare -r description="Checks network access by pinging google."
declare -r usage="Usage: $script_name [number of pings (default: $default_retries)]"

log_info() {
  printf >&2 '[INFO] %s\n' "$1" # (1)!
}

log_error() {
  # Highlight errors in red if we're on a TTY.
  if [[ -t 2 ]]; then
    printf >&2 '\e[0;31m[ERROR] %s\e[0m\n' "$1"
  else
    printf >&2 '[ERROR] %s\n' "$1"
  fi
}

if (($# == 1)) && [[ "$1" == "-h" || "$1" == "--help" ]]; then
  printf '%s\n%s\n' "$description" "$usage"
  exit 0
fi
if (($# > 1)); then
  log_error "Invalid usage."
  printf '%s\n' "$usage"
  exit 2 # (2)!
fi

declare -r -i count=$(("${1:-}" || $default_count))

do_ping() {
  ping -c "$count" google.com > /dev/null 2> /dev/null || return $?
}

main() {
  log_info "Starting..."
  if ! do_ping; then
    log_error "Cannot ping Google. Check cables?"
    return 1
  fi
  log_info "Done."
}

main || exit 1 # (3)!
# Alternative: main || exit $? # (4)!
```

1. Always log to stderr; stdout is for machine-readable output.
2. `exit 2` for usage errors.
3. If `main` errored, exit 1.
4. You can use `|| exit $?` to forward `main`’s return code.

### Parsing command-line arguments

Either keep it simple as in the above example, or use a `case` statement.
Always use `case` if there are any `--options`.
See [`todos.sh`](../scripts/todos.sh) for a `case` example.

!!! rationale

    `getopts`, as well the variant of `getopt` on BSD, cannot parse --long-style options.
    `getopt` has other differences between distributions, as well.
    These issues make `case` statements a better choice.

## Docker

Consider using a linter such as [hadolint](https://github.com/hadolint/hadolint).

### `ENV` commands

Break `ENV` commands into one line per command.
`ENV` no longer adds a layer in new Docker versions,
so there is no need to chain them on a single line.

### Labels

Use [Open Containers labels](https://github.com/opencontainers/image-spec/blob/master/annotations.md),
including:

- `org.opencontainers.image.version`
- `org.opencontainers.image.vendor`
- `org.opencontainers.image.title`
- `org.opencontainers.image.url`
- `org.opencontainers.image.documentation`

### Multistage builds

Where applicable, use a multistage build to separate _build-time_ and _runtime_ to keep containers slim.
For example, when using Maven, Maven is only needed to assemble, not to run.

Here, `maven:3-eclipse-temurin-21` is used as a base image, maven is used to compile and build a JAR artifact,
and everything but the JAR is discarded.
`eclipse-temurin:21` is used as the runtime base image, and only the JAR file is needed.

```Docker
FROM maven:3-eclipse-temurin-21 AS build
WORKDIR /root
RUN --mount=type=cache mvn package

FROM eclipse-temurin:21 AS run
ARG JAR_FILE=target/*.jar
COPY --from=build $JAR_FILE my-app.jar
EXPOSE 443
ENTRYPOINT java -jar my-app.jar
```

\*[TTY]: [TeleTYpe device](<https://en.wikipedia.org/wiki/Tty_(Unix)>)
