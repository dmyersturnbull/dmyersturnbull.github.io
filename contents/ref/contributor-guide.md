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

Feel free to ask a question on the Discussions tab.
New issues and pull requests are also welcome.
Contributors are asked to abide by the
[GitHub community guidelines](https://docs.github.com/en/site-policy/github-terms/github-community-guidelines)
and the [Contributor Code of Conduct, version 2.0](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).

## Starting work

Install the [GitHub CLI](https://cli.github.com/) if you haven’t already.
You may want to discuss with the maintainers before starting any work to avoid wasting any time.
Please create an issue for this.

To fork and clone, run

```bash
gh repo fork https://github.com/<org>/<repo> --default-branch-only --clone
```

## Coding & committing

It is best to configure Git to use your GPG keys.
See the [Git, SSH, and GPG guide](../guide/git-ssh-and-gpg.md).

For open source projects, commit using `--signoff`,
which indicates certifies under the [Developer Certificate of Origin](https://developercertificate.org/)
that you have the right to submit your contributions under this project’s license.

### Python

Always run `hatch run fmt` before committing to auto-format your code.

To commit, use `hatch run commit --signoff`.
You can also use `git commit` directly by following [supplemental commit messages](maintainer-guide.md#Reference).

`--signoff` indicates certifies under the [Developer Certificate of Origin](https://developercertificate.org/)
that you have the right to submit your contributions under this project’s license.

## Other languages

Format your code before committing.
Commit with `git commit --signoff`.

## Submitting a pull request

!!! tip
    Feel free to solicit feedback on your changes by opening a draft pull request.
    After that, `git push` to your fork to update the pull request.
    To start, run

    ```bash
    gh pr create --fill --web --draft
    ```

Consider using `rebase -i` to clean up your commits.
Edit (`e`) commit messages to clarify them and fixup (`f`) any messages that should be excluded.

To open a pull request, run

```bash
gh pr create --fill --title '<type>: <message>' --web
```

(Refer to the table below for the types.)
When you’re ready, mark your pull request as "ready for review" on github.com or by running

```bash
gh pr ready <id>
```

## Conventions

Maintainers can fix up your commits.
You can also refer to the [coding conventions](https://dmyersturnbull.github.io/ref/contributor-guide/).

## Commit and issue types

The allowed commit types are:
`security`, `deprecation`, `feature`, `fix`, `perf`, `build`, `docs`, `test`, `ci`, `refactor`, `style`, and `chore`.
Note that there is no `revert` type; instead, use the type that reflects the reversion commit.
This will ordinarily be the same type as the commit being reverted.

See the [supplemental labels document](../ref/issue-labels.md) for complete information.
