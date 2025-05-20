# Git plumbing

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This describes how to solve some common Git problems that require piping Git output.

!!! warning "Note: _plumbing_ vs. _porcelain_"

    Git distinguishes between
    [_porcelain_ and _plumbing_ commands](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain),
    where porcelain IO is human-readable and plumbing IO is machine-readable.
    Unfortunately, for historical reasons, Git is extremely inconsistent about this distinction.
    In fact, `git status` is a porcelain command, but `git status --porcelain` is plumbing.
    See [VonC's explanation on StackOverflow](https://stackoverflow.com/a/6978402/4024340).

## Simple things

### Is file `$f` checked in?

```bash
git ls-files --error-unmatch "$f" > /dev/null 2> /dev/null
```
