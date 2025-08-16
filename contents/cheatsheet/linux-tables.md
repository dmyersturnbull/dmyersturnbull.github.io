---
tags:
  - Linux
  - Bash
---

# Linux and Bash tables

Useful cheatsheet tables for Linux and Bash.

## Filesystem

### Types of inodes

| type              | in `ls` | description                                      |
| ----------------- | ------- | ------------------------------------------------ |
| regular file      | `-`     | real file                                        |
| directory         | `d`     | real directory                                   |
| symbolic link     | `l`     | pointer to another inode                         |
| character device  | `c`     | unbuffered device like a terminal or `/dev/null` |
| block device      | `b`     | buffered device like a disk or partition         |
| socket            | `s`     | UNIX domain socket for IPC                       |
| named pipe (FIFO) | `p`     | named pipe for IPC                               |

/// table-caption
<b>Inode types with associated symbols in `ls -l`</b>
///

### Attributes of inodes

| attribute    | applies to                | **Description**                     |
| ------------ | ------------------------- | ----------------------------------- |
| `st_ino`     | all                       | inode number                        |
| `st_mode`    | all                       | type and permissions (bitmask)      |
| `st_nlink`   | all                       | number of hard links                |
| `st_uid`     | all                       | owner user ID                       |
| `st_gid`     | all                       | owner group ID                      |
| `st_size`    | file, symlink             | size in bytes                       |
| `st_atime`   | all                       | last access                         |
| `st_mtime`   | all                       | last modification                   |
| `st_ctime`   | all                       | last status change (e.g. owner)     |
| `st_blksize` | all                       | preferred I/O block size            |
| `st_blocks`  | all                       | number of 512-byte blocks allocated |
| `st_rdev`    | char device, block device | device id (major+minor)             |

## Bash

### Bash `[[ ]]` test operators

| operator | syntax            | meaning                                  |
| -------- | ----------------- | ---------------------------------------- |
| `==`     | `str1 == str2`    | `str1` **equals** `str2`                 |
| `!=`     | `str1 != str2`    | `str1` does **not equal** `str2`         |
| `<`      | `str1 < str2`     | `str1` **precedes** `str2`               |
| `>`      | `str1 > str2`     | `str` **succeeds** `str2`                |
| `=~`     | `str =~ regex`    | `str` **matches** `regex` pattern        |
| `-v`     | `-v var`          | `var` is a **defined variable**          |
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

#### Testing whether a name is defined

| syntax                          | meaning                  | notes                |
| ------------------------------- | ------------------------ | -------------------- |
| `type name > /dev/null`         | `name` is defined        | general              |
| `alias name > /dev/null`        | `name` is an alias       |                      |
| ~~`declare -F name`~~           | ~~`name` is a function~~ | always `true` in ZSH |
| `typeset -f myfunc > /dev/null` | `name` is a function     |                      |

/// table-caption
<b>Other common tests.</b>
///

## Core utilities

### Format specifiers by printf flavor

!!! note

    [`find -printf`](https://manpages.debian.org/bookworm/findutils/find.1.en.html#printf)
    ([man7 link](https://man7.org/linux/man-pages/man1/find.1.html`))
    is not related to find.

| Specifier | Meaning                         | Bash | C   | awk |
| --------- | ------------------------------- | ---- | --- | --- |
| `%s`      | String                          | ✅   | ✅  | ✅  |
| `%b`      | Escapes processed string        | ✅   | ❌  | ❌  |
| `%d`      | Signed decimal integer          | ✅   | ✅  | ✅  |
| `%i`      | Signed decimal integer          | ✅   | ✅  | ✅  |
| `%u`      | Unsigned decimal integer        | ✅   | ✅  | ✅  |
| `%x`      | Unsigned hex (lowercase)        | ✅   | ✅  | ✅  |
| `%X`      | Unsigned hex (uppercase)        | ✅   | ✅  | ✅  |
| `%o`      | Unsigned octal                  | ✅   | ✅  | ✅  |
| `%f`      | Float (fixed-point)             | ✅   | ✅  | ✅  |
| `%e`      | Float (scientific, lowercase)   | ✅   | ✅  | ✅  |
| `%E`      | Float (scientific, uppercase)   | ✅   | ✅  | ✅  |
| `%g`      | Float, shortest of `%f` or `%e` | ✅   | ✅  | ✅  |
| `%G`      | Float, shortest of `%f` or `%E` | ✅   | ✅  | ✅  |
| `%c`      | Single character                | ✅   | ✅  | ✅  |
| `%p`      | Pointer or path                 | ❌   | ✅  | ✅  |
| `%n`      | Store # chars written (C only)  | ❌   | ⚠️  | ❌  |
| `%%`      | Literal percent sign            | ✅   | ✅  | ✅  |
| `%q`      | Shell-escaped string            | ✅   | ❌  | ❌  |
| `%Nd`     | Zero-padded to `N` chars        | ✅   | ✅  | ✅  |
| `%-Ns`    | Left-aligned string             | ✅   | ✅  | ✅  |

<small>
⚠️ = dangerous and should not be used
</small>
