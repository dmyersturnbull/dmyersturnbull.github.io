# Git recipes

Sticky notes for commands that I keep forgetting.

## Miscellaneous

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

## Editing – commit, rebase, etc.

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

This will

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

## Diffs

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
