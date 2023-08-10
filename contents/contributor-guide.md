# Contributing guide

Feel free to ask a question on the Discussions tab.
New issues and pull requests are also welcome.
Contributors are asked to abide by the
[GitHub community guidelines](https://docs.github.com/en/site-policy/github-terms/github-community-guidelines)
and the [Contributor Code of Conduct, version 2.0](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).

## Starting work

!!! note
It is helpful to configure Git to use your GPG keys. - [Generate a GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) - [Tell Git about your key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key) - [Add a GPG key to your GitHub account](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)

You may want to discuss with the maintainers before starting any work to avoid wasting any time.
Please create an issue for this.

To fork and clone, run:

```bash
gh repo fork https://github.com/<org>/<repo> --default-branch-only --clone
```

## Making changes & committing

Always run `hatch run fmt` before committing to auto-format your code.

To commit, use `hatch run commit --signoff`.
You can also use `git commit` directly by following [supplemental commit messages](#supplemental-commit-messages).

`--signoff` indicates certifies under the [Developer Certificate of Origin](https://developercertificate.org/),
that you have the right to submit your contributions under this project’s license.

## Submitting a pull request

!!! tip
Feel free to solicit feedback on your changes by opening a draft pull request.
After that, `git push` to your fork to update the pull request. To start, run:

    ```bash
    gh pr create --fill-first --web --draft
    ```

Consider using `rebase -i` to clean up your commits.
Edit (`e`) commit messages to clarify them and fixup (`f`) any messages that should be excluded.

To open a pull request, run:

```bash
gh pr create --fill --title '<type>: <message>' --web
```

(Refer to the table below for the types.)
When you’re ready, mark your pull request as "ready for review" on github.com or by running:

```bash
gh pr ready <id>
```

## Commit and issue types

| Type        | Label               | Description                         |
| ----------- | ------------------- | ----------------------------------- |
| `security:` | `type: security`    | Fix a security issue                |
| `feat:`     | `type: feature`     | Add or change a feature             |
| `fix:`      | `type: fix`         | Fix a bug                           |
| `docs:`     | `type: docs`        | Add or modify docs or examples      |
| `build:`    | `type: build`       | Modify build, including Docker      |
| `perf:`     | `type: performance` | Increase speed / decrease resources |
| `test:`     | `type: test`        | Add or modify tests                 |
| `refactor:` | `type: refactor`    | Refactor source code                |
| `style:`    | `type: style`       | Improve style of source code        |
| `chore:`    | `type: chore`       | Change non-source code              |
| `ci:`       | `type: ci`          | Modify CI/CD                        |
