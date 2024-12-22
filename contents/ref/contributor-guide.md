<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Contributor guide

!!! abstract "How to use these docs"

    These docs are meant to be linked to.
    Include a link in your project’s readme or `CONTRIBUTING.md` file.
    E.g.,
    ```markdown
    See https://dmyersturnbull.github.io/ref/contributor-guide/
    but disregard the `security:` commit type, which we don’t use.
    ```

    Or just link to individual sections.

Contributions, including feature requests, bug reports, and pull requests, are always welcome.

Contributors are asked to abide by the
[GitHub community guidelines](https://docs.github.com/en/site-policy/github-terms/github-community-guidelines)
and the [Contributor Code of Conduct, version 2.0](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).

We try to keep contributing changes as easy as possible.
To that end, only maintainers are responsible for final commit messages, code style, etc.;
you don’t need to follow any conventions.

## Contributing changes, step-by-step

### Open an issue and ask

Before writing any code, please **open an issue** to discuss the intended change.
Please only address one issue per PR, and write `Fixes #123` in the description.
Feel free to open a PR well before it’s complete; just mark it as a draft until it’s ready for review.

### Setting up

These steps are highly recommended, but they are not required to submit a PR.

1.  Configure Git to auto-convert line endings.

    === "Linux and macOS"

        `git config --global core.autocrlf input`

    === "Windows"

        `git config --global core.autocrlf true`

2.  Configure Git to use your GPG keys.
    See the [Git, SSH, and GPG guide](../guide/git-ssh-and-gpg.md).

3.  Install [GitHub CLI](https://cli.github.com/).
    Note that the instructions below use it.

To fork and clone, run

```bash
gh repo fork https://github.com/<org>/<repo> --default-branch-only --clone
```

Install or upgrade [pre-commit](https://pre-commit.com/) by running `pip install pre-commit --upgrade`.
Then, inside the repository, run `pre-commit install` to initialize pre-commit.

### Make the changes

Don’t worry about code style: both pre-commit and a GitHub workflow will handle that.
If you want, you can refer to the
[coding conventions guide](https://dmyersturnbull.github.io/convention/)
for conventions beyond simple formatting.
Note that those rules are extensive and ordinarily the responsibilty of maintainers.

Limit changes to those needed to close the issue associated with the PR.
When your PR gets accepted, your commits get squashed into one commit linked to exactly one issue,
which is automatically closed.

!!! warning

    Making unnecessary or unrelated changes in your PR is perhaps the only way to get it rejected.
    The maintainers can reformat code, fix bugs, and rewrite a PR description.
    However, they have no way to split up your PR.

### Commit the changes

You do not need to follow any convention for commit messages.
Write a message that you think is helpful.

If your commits are messy (e.g. some are just fixups), consider fixing them `rebase -i`.
Edit (`e`) commit messages to clarify them and fixup (`f`) any messages that should be excluded.

### Open a PR

To open a pull request, run

```bash
gh pr create --fill --title '<issue-title>' --web
```

When you’re ready, mark your PR as "ready for review" on GitHub or by running

```bash
gh pr ready <id>
```

Feel free to solicit feedback on your changes by opening a draft pull request.
After that, `git push` to your fork to update the pull request.
To start, run

```bash
gh pr create --fill --web --draft
```
