# Bash tricks

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This lists some tips, and details how to do certain common-but-difficult things in Bash correctly.

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

## Comparisons

| operator | syntax            | meaning                                  |
| -------- | ----------------- | ---------------------------------------- |
| `==`     | `str1 == str2`    | `str1` **equals** `str2`                 |
| `!=`     | `str1 != str2`    | `str1` does **not equal** `str2`         |
| `<`      | `str1 < str2`     | `str1` **precedes** `str2`               |
| `>`      | `str1 > str2`     | `str` **succeeds** `str2`                |
| `=~`     | `str =~ regex`    | `str` **matches** `regex` pattern        |
| `-z`     | `-z str`          | `str` is **empty**                       |
| `-n`     | `-n str`          | `str` is **nonempty**                    |
| `-e`     | `-e path`         | `path` **exists**                        |
| `-f`     | `-f path`         | `path` is a **regular file**             |
| `-d`     | `-d path`         | `path` is a **directory**                |
| `-L`     | `-L path`         | `path` is a **symbolic link**            |
| `-h`     | `-h path`         | (alias for `-L`)                         |
| `-b`     | `-b path`         | `path` is a **block device**             |
| `-c`     | `-c path`         | `path` is a **character device**         |
| `-p`     | `-p path`         | `path` is a **named pipe**               |
| `-S`     | `-S path`         | `path` is a **socket**                   |
| `-u`     | `-u path`         | `path` has **set-user-ID** bit           |
| `-g`     | `-g path`         | `path` has **set-group-ID** bit          |
| `-k`     | `-k path`         | `path` has **sticky** bit                |
| `-O`     | `-O path`         | `path` is **owned** by effective user    |
| `-G`     | `-G path`         | `path` is **owned** by effective group   |
| `-s`     | `-s file`         | `file` is **nonempty**                   |
| `-r`     | `-r file`         | `file` is **readable**                   |
| `-w`     | `-w file`         | `file` is **writable**                   |
| `-x`     | `-x file`         | `file` is **executable**                 |
| `-t`     | `-t descriptor`   | `descriptor` **is a tty**                |
| `-nt`    | `path1 -nt path2` | `path1` is **newer** than `path2`        |
| `-ot`    | `path1 -ot path2` | `path1` is **older** than `path2`        |
| `-ef`    | `path1 -ef path2` | `path1` is the **same inode** as `path2` |
| `-N`     | `-N path`         | `path` has **mtime > atime**             |

/// table-caption
<b>Test operators (`[[ ]]`).</b>
///

## Miscellaneous notes

- `man builtin` covers all builtins for your shell.

- `my_func() { }` fails in Bash but not ZSH.
  Bash requires functions to have contents, so use `my_func() { true }`.
- For security, be extremely careful with `env`, `export`, and `declare`.
  Calling them without arguments may leak secrets.
