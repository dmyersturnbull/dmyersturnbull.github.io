# Scripts and build files

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Command-line tools

### Standard streams

As long as doing so sensible, CLI tools should read from stdin and write to stdout.
In either cases, they must direct logging messages to stderr, never to stdout.

### Arguments

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

Use `-` for single-character options and `--` for long ones (e.g. `--user`).
Allow both `--option <arg>` and `--option=<arg>`.

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

Use [bertvv’s Bash guidelines](https://bertvv.github.io/cheat-sheets/Bash.html)
alongside the following rules and exceptions.

1. As the only exception: `$var` is preferred over `${var}` where either would work.
2. Use `#!/usr/bin/env bash`.
3. Read stdin where applicable, and reserve stdout for machine-readable output.
   _For usage errors:_ write the usage to stderr; `exit 2`.
   _For `--help`_: write the usage and program description to stdout; `exit 0`.
4. Use `my_fn() {}`, **not** `function my_fn {}`, and **definitely not** `function my_fn() {}`.
5. Always explicitly `exit`.
6. [Use `printf`, not `echo`](../cheatsheet/bash-tips.md#use-printf-not-echo).

!!! note

    I recently (2024-08) changed my mind on `$var` vs. `${var}`.
    I previously followed [bertvv](https://github.com/bertvv)’s advice and used forced `${}`.
    That adds clarity, but it contradicts my
    [less > more principle](https://dmyersturnbull.github.io/convention/#principles).

### Example

```bash
#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright 2024, Contributors to the gamma package
# SPDX-PackageHomePage: https://github.com/the-gamma-people/gamma
# SPDX-License-Identifier: MIT
set -o errexit -o nounset -o pipefail # (1)!

declare -r prog_name=$(basename "$0")
declare -r -i default_min=2
_usage="Usage: $prog_name in-dir [min-hits=$default_min]"
_desc="Computes gamma if in-dir contains < min-hits results."

if (( $# == 1 )) && [[ "$1" == "-h" || "$1" == "--help" ]]; then
	printf '%s\n%s\n' "$_desc" "$_usage"
	exit 0
fi
if (( $# == 0 )) || (( $# > 2 )); then
  >&2 printf 'Invalid usage.\n%s\n' "$_usage" # (2)!
  exit 2 # (3)!
fi
declare -r in_dir="$1"
declare -r -i min_hits=$(( "${2:-}" || $default_min ))

gamma::fail() {  # (4)!
	>&2 printf '[FATAL] %s\n' "$1"
	exit 1 # (5)!
}

gamma::must_compute() {
  _count=$(( ls -l -- "$in_dir" | wc -l ))
  return (( _count < $min_hits ))
}

gamma::compute() {
  ping google.com || fail "Cannot ping Google. Check cables?"
}

gamma::main() {
  >&2 printf '[INFO] Initializing...\n'
  gamma::must_compute && gamma::compute
}

gamma::main
exit 0 # (6)!
```

1. [Set](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
   `nounset`, `errexit`, and `pipefail`.
   With `IFS=$'\n\t'`, these options are sometimes called
   [Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/).
   Using `IFS=$'\n\t'` is generally safer, but it’s less interoperable.
2. Always log to stderr.
3. `exit 2` for usage errors.
4. Omit `function`. Using a package prefix (e.g. `gamma::`) can be helpful.
5. `exit` with 1 or 3–125.
   See [`sysexits.h`](https://manpages.ubuntu.com/manpages/lunar/man3/sysexits.h.3head.html) (ignoring `EX_USAGE`).
6. Without this line, the script returns `1` if `gamma::must_compute` returns `1`.
   If using `must_compute`’s exit code is desired, use `exit $?`.

!!! warning "Don’t rely on Strict Mode"

    Even if you set `noset`, `errexit`, and `pipefail`, write the code as though they’re not enabled.
    Having to switch between strict and nonstrict styles is difficult, and you’re likely to make a mistake.
    Practicing the robust way only reinforces it in your memory (and helps others reading it, too).
    And code that relies on these options are brittle when moved or copied to a script (or shell) that doesn’t set them.
    They can even get unset midway through a script; e.g. when `source`ing another script.

### Parsing command-line arguments

Either keep it simple as in the above example, or use a `case` statement.
See [`todos.sh`](../guide/files/todos.sh) for a `case` example.

!!! rationale

    `getopts`, as well the variant of `getopt` on BSD, cannot parse --long-style options.
    `getopt` has other differences between distributions, as well.
    This makes `case` statements a substantially better choice.

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
