---
tags:
  - CLI
---

# CLI conventions

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Arguments

Distinguish between optional arguments (_options_ or _switches_) and required, positional arguments.

- Optional arguments MUST be `--named` options using the Linux convention of
  `--` for long names and `-` for short (single-letter) names.
- Required arguments SHOULD be positional unless there are more than 3.

!!! note

    For clarity, use these terms in usage and docs:

    - _positional argument_ (prefix with _required_ or _optional_ if needed)
    - _option_ (whose name starts with `-` or `--`)
    - _flag_ (preferred term for nullary options)

Prefer named options over positional arguments and limit positional argument lists to ≤ 3 items.
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

## Exit codes

For usage errors, exit with code 2
([like shell bulletins do)](https://tldp.org/LDP/abs/html/exitcodes.html)).
Use 1 for other general errors.
When types of errors need to be distinguished, use codes in the range 3–125.
It may be helpful to reference
[`sysexits.h`](https://manpages.ubuntu.com/manpages/lunar/man3/sysexits.h.3head.html)
in the C standard library (ignoring `EX__BASE` and `EX_USAGE`).
Otherwise, just be consistent.

## Standard streams

As long as doing so sensible, CLI tools should read from stdin and write to stdout.
In either cases, they must direct logging messages to stderr, never to stdout.

### stdout and stdin

Shell scripts make it easy to chain, piping data from one command to the next without storage IO.
This raises throughput, lowers latency, avoids wear on storage devices, and lowers energy usage.
It also simplifies parallelization and leaves code more concise and obvious.

So, default to using stdout and stdin instead of files.
Use stdout only for machine-readable output, **not** logging.

### stderr

Use stderr for all logging, not just errors.

<b>Note about `--help` and usage errors:</b>
When calling `my-script --help`, the expected output is a usage string,
so it should be written to stdout despite not being very machine-readable.
For usage errors (e.g. `my-script --obviously-invalid-option`), write to stderr instead.

## Standard paths

Use the
[XDG Base Directory Standard](https://specifications.freedesktop.org/basedir-spec/latest/),
including on macOS.

## ANSI escape codes

CLI apps may want to use
[ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code).
Codes other than color and style, such as those that scroll or move the cursor,
should only be used when and as expected (necessarily requiring that the terminal is a [TTY]).

### Color and style

<a name="color"></a>
In general, terminal apps should support using color and/or style via
[ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code)
to enhance readability.

#### When to enable

If your app supports color and/or style, it should be enabled IF AND ONLY IF _EITHER_:

- [`NO_COLOR`](https://no-color.org/) is **defined and non-empty** _AND EITHER_
  `--color` (or similar CLI flag or option) was passed _OR_ the output stream is a [TTY]
  (e.g. as detected by `[[-t 2]]).
- _OR_ [`FORCE_COLOR`](https://force-color.org/) is **defined and non-empty**.

!!! note

    Apps should check only the environment variables `NO_COLOR` and `FORCE_COLOR`.
    and **ignore other environment variables**, including `TERM`, `CLICOLOR`, and `CLICOLOR_FORCE`.

    These variables are considered enabled when non-empty, as specified in their standards
    [https://no-color.org](https://no-color.org/)
    and
    [https://force-color.org](https://force-color.org/):
    **`NO_COLOR=0`, `FORCE_COLOR=off`, `NO_COLOR=\ `, etc. are still considered enabled**.

    **Treat styles (e.g. bold) identically, using `NO_COLOR`, `FORCE_COLOR`, `--color`, etc.**

#### Compatibility

When using colors, be aware that users’ terminal color schemes vary dramatically.
To accommodate light and dark modes (backgrounds), most apps should not set background colors.
Larger apps may consider user-configurable colors, such as with app-specific environment variables.

Bold, bright, dim, italic, and underline are widely but not universally supported.
Use these “secondary styling”; for example, underline hyperlinks, italicize new terms, etc.
Most other codes are rarely supported and should be avoided.

#### Accessibility, etc.

Never rely exclusively on color or style;
all essential information must be parsable from visible characters (for humans and machines).
Also, don’t go overboard: 4 colors is nice, 8 is confusing, and 16 sends users to ophthalmologists.

*[TTY]: [TeleTYpe device](<https://en.wikipedia.org/wiki/Tty_(Unix)>)
