---
tags:
  - Git
---

# Git cheatsheet

## Recipes

Sticky notes for commands that I keep forgetting.

### Miscellaneous

#### Getting help

```bash
git help --all
git help help
```

#### Optimize a repo

!!! warning

    Don’t run `git gc` while another `git gc` or a
    [`git maintenance`](https://git-scm.com/docs/git-maintenance)
    task is running,
    If aggressive options are used, your local repo could be corrupted.

Git stores metadata as loose files until it chooses to consolidate them.
Run `git gc` manually before backups:

```bash
if [[ "$(uname)" == Darwin ]]; then
  chflags -R nouchg .git/*
fi
git gc --prune=1.day
git fetch --prune
```

### Editing – commit, rebase, etc.

#### Unstage a file

!!! danger

    If you omit `--staged`, you’ll lose your changes.

To remove a file from the index **without affecting the working directory**, use

```bash
git restore --staged file
```

#### Amend without editing

To avoid repeating the message, use `--no-edit`:

```bash
git commit --amend --no-edit
```

#### Fix a commit you just pushed

!!! warning

    Although `--force-with-lease` is **much** safer than `--force`,
    this still rewrites your branch’s history, which can confuse and inconvenience collaborators.

```bash
if [[ "$(git branch --show-current)" =~ master|main ]]; then
  printf >&2 \
    "%bRefusing on ref '%s'.**\n%b" "\e[1;31m" \
    "$(git rev-parse --abbrev-ref HEAD)" "\e[0m"
else
  git commit --all --amend --no-edit
  git push --force-with-lease
fi
```

#### Sign the commit

Use `-S<id>`, which is a single argument.
For example, if the GPG key is named `git`, use

```bash
git commit -Sgit
```

#### Tag for release

Assuming `tag.gpgSign` is correct, `-s`/`--sign` is sufficient.
Example:

```bash
git commit --sign v0.1.0-rc.0
git push --signed --tags
```

### Diffs

#### Better diffs

Use `--histogram` (a much better diff algorithm) and `--color-moved` to show rearranged lines.

```bash
git diff --histogram --color-moved ref1..ref2
```

#### Only show modified files

To only show files that were edited (i.e. not added, deleted, etc.):

```bash
git diff --diff-filter=M
```

#### Find overly similar files

You can abuse Git’s copy-detection feature like this:

```bash
git diff --diff-filter=C --find-copies=1% --find-copies-harder
```

#### Regex search

Use `-G'regex'` to find (edited/added/deleted) lines that match `regex`.
For example, to diff only Markdown lines like `- Category 1C [...]`, run

```bash
git diff --histogram --color-moved -G'^- Category \d+[A-Z]' **/*.md
```

## Plumbing commands

Common Git problems that require piping Git output.

Git distinguishes between
[_porcelain_ and _plumbing_ commands](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain),
where porcelain IO is human-readable and plumbing IO is machine-readable.
Unfortunately, for historical reasons, Git is extremely inconsistent about this distinction.
In fact, `git status` is a porcelain command, but `git status --porcelain` is plumbing.
See [VonC’s explanation on StackOverflow](https://stackoverflow.com/a/6978402/4024340).

### Simple things

#### Is file `$f` checked in?

```bash
git ls-files --error-unmatch "$f" > /dev/null 2> /dev/null
```

#### Table of branches

```bash
__git_branch_table() {
  local sep=$'\x1F'
  git for-each-ref \
    --sort=-committerdate \
    --format="%(refname:rstrip=-1)$sep%(committerdate:short)$sep%(authorname)$sep%(objectname:short)$sep%(subject)" \
    refs/heads/ \
    | column -t -s "$sep"
}
```

## Tables

### [Refspec](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec)

Useless (redundant) syntax types use ~~strikethrough~~.

| Syntax    | Meaning                                         | Example           | Valid in                                   |
|-----------|-------------------------------------------------|-------------------|--------------------------------------------|
| `refname` | Branch/tag by full name                         | `refs/heads/main` | `log`, `diff`, `show`, `blame`, `rev-list` |
| `refname` | Branch/tag by short name                        | `main`            | `log`, `diff`, `show`, `blame`, `rev-list` |
| `sha1`    | SHA-1 or abbreviated SHA-1                      | `f5c3e2a `        | `log`, `diff`, `show`, `blame`, `rev-list` |
| `ref~n`   | `n`th first-parent ancestor of `ref`            | `HEAD~2`          | `log`, `diff`, `show`                      |
| ~~`ref^`~~ | ~~First parent of `ref` (equiv. to `ref~1`)~~   | ~~`HEAD^`~~       | ~~`log`, `diff`, `show`~~                  |
| `ref^n`   | `n`th parent of merge commit `ref`              | `main^2`          | `log`, `diff`, `show`                      |
| `a..b`    | Commits reachable from `b` but not `a`          | `feat..main`      | `log`, `diff`, `rev-list`                  |
| `a...b`   | Commits reachable from `a` xor `b`              | `feat...main`     | `log`, `diff`                              |
| `ref^@`   | All parents of `ref` (equiv. to `ref^1`, …)     | `HEAD^@`          | `log`, `diff`                              |
| `ref@{n}` | Value of `ref` in the reflog `n` moves ago      | `HEAD@{3}`        | `log`, `reflog`, `show`                    |
| `ref@{date}` | Value of `ref` at the specified date-time       | `main@{now}`      | `log`, `show`                              |
| ~~`@{1}`~~ | ~~`HEAD`~~                                      | ~~`@{1}`~~        | ~~`log`, `show`~~                          |
| `@{-n}`   | Value of `HEAD` in the reflog `n` moves ago     | `@{-1}`           | ~~`log`, `show`                            |
| `ref^0`   | Underlying object for annotated tag `ref`       | `v1^0`            | `show`, `log`, `diff`                      |
| ~~`ref^{}`~~ | ~~Underlying object for annotated tag `ref`~~   | ~~`v1^{}`~~       | ~~`show`, `log`, `diff`~~                  |
| `ref -- path` | Commits reachable from `ref` that affect `path` | `HEAD -- src/`    | `log`, `diff`, `blame`                     |

<b>†</b>
All is `log`, `diff`, `show`, `blame`, `rev-list`.
