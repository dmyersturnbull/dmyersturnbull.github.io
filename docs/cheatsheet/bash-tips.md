---
tags:
  - Bash
---

# Bash tips

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

How to do certain common-but-difficult things correctly.
Plus reminders of commands I routinely forget.

## General

### Use printf, not echo

[POSIX recommends against `echo`](https://pubs.opengroup.org/onlinepubs/9699919799/)
because it has serious limitations,
including platform-specific behavior, inconsistent `\n` handling,
and an n-ary argument list
[not terminated by `--`](https://pubs.opengroup.org/onlinepubs/9699919799/).

### How to get a script’s own directory

Doing this correctly is a bit tricky.

Note these features:

- `--` is needed because, outside a script, `$0` is (e.g.) `-z`,
  which `readlink` assumes is an option and errors with an unhelpful message.
- The `|| exit $?` after the `readlink` is needed to exit the subshell immediately.
  Otherwise, `dirname` is called but with no stdin, causing it to return `.`.
- The outer `|| exit $?` catches any unlikely nonzero exits from `dirname`.

A tiny caveat: This will fail on a fraction of outrageously strange paths.
In particular, it will break on a path that contains a newline --
a character that ext4 and btrfs support and that Linux will technically accept.
But this would cause more serious problems, and if you’re naming files like this, stop.

```bash
this_dir=$(dirname "$(readlink -f -- "$0" || exit $?)") || exit $?
```

This function seems to work in Bash 5.2 on Ubuntu 25.04 and macOS 24.

```bash
get_type() {
  local v re
  v="$(type "$1" || true)"
  re="[[:space:]]is[[:space:]]an?[[:space:]]"
  if [[ ! "$v" =~ $re ]]; then
    echo command
    return
  fi
  case "$v" in
    *alias* )
      echo alias
      ;;
    *function* )
      echo 'function'
      ;;
    *builtin* )
      echo builtin
      ;;
    *reserved* )
      echo keyword
      ;;
    *is* )
      echo command
      ;;
    *not* )
      echo undefined
      ;;
    *)
      echo unknown
      ;;
  esac
}
```

## Miscellaneous notes

- `man builtin` covers all builtins for your shell.

- `my_func() { }` fails in Bash but not ZSH.
  Bash requires functions to have contents, so use `my_func() { true }`.
- For security, be extremely careful with `env`, `export`, and `declare`.
  Calling them without arguments may leak secrets.
