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
