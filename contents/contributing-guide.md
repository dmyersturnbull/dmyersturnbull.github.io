# Contributing guide

## For new contributors

Feel free to ask a question on the Discussions tab.
New issues and pull requests are also welcome.
Contributors are asked to abide by the
[GitHub community guidelines](https://docs.github.com/en/site-policy/github-terms/github-community-guidelines)
and the [Contributor Code of Conduct, version 2.0](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).

### Starting work

You may want to discuss with the maintainers before starting any work to avoid wasting any time.
Please create an issue for this.

To fork and clone, run:

```bash
gh repo fork https://github.com/<org>/<repo> --default-branch-only --clone
```

### Making changes & committing

Always run `hatch run fmt` before committing to auto-format your code.

To commit, use `hatch run commit --signoff`.
You can also use `git commit` directly by following [supplemental commit messages](#supplemental-commit-messages).

`--signoff` indicates certifies under the [Developer Certificate of Origin](https://developercertificate.org/),
that you have the right to submit your contributions under this project’s license.

### Submitting a pull request

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

!!! example
`bash gh pr create --fill --title 'feat: add new schema' --web `

When you’re ready, mark your pull request as "ready for review" on github.com or by running:

```bash
gh pr ready <id>
```

### Supplemental: Commit messages

We follow [Conventional Commits](https://www.conventionalcommits.org/) using the following types.
The general pattern for the subject is `<type>[(<scope>)][!]: <subject>`,
where `(<scope>)` is a empty, `plugins`, or `i18n` and `!` denotes a breaking change.
Examples:

- `feat!: add schema`
- `doc(i18n): add JP translation`
  This table also shows how commit messages map to issue labels and changelog sections.

| Type        | Label               | Changelog section  | semver | Description                         |
| ----------- | ------------------- | ------------------ | ------ | ----------------------------------- |
| `security:` | `type: security`    | `🔒 Security`      | minor  | Fix a security issue                |
| `feat:`     | `type: feature`     | `✨ Features`      | minor  | Add or change a feature             |
| `fix:`      | `type: fix`         | `🐛 Bug fixes`     | patch  | Fix a bug                           |
| `docs:`     | `type: docs`        | `📝 Documentation` | patch  | Add or modify docs or examples      |
| `build:`    | `type: build`       | `🔧 Build system`  | minor  | Modify build, including Docker      |
| `perf:`     | `type: performance` | `⚡️ Performance`  | patch  | Increase speed / decrease resources |
| `test:`     | `type: test`        | `🚨 Tests`         | N/A    | Add or modify tests                 |
| `refactor:` | `type: refactor`    | ignored            | N/A    | Refactor source code                |
| `style:`    | `type: style`       | ignored            | N/A    | Improve style of source code        |
| `chore:`    | `type: chore`       | ignored            | N/A    | Change non-source code              |
| `ci:`       | `type: ci`          | ignored            | N/A    | Modify CI/CD                        |

**Full pattern:**

```text
<type>[(<scope>)][!]: <subject>

<body>

[BREAKING CHANGE: <breaking>]
[Closes: #<issue>]
[*: <author>]+

Signed-off-by: <author>
"""
```

!!! example

```text
feat!: add major new feature

We added a major new feature.
Here are details: ta-da.

BREAKING CHANGE: many things

Closes: #14
Co-authored-by: Amelia Johnson <amelia@dev.com>
Co-authored-by: Cecilia Johnson <cecilia@dev.com>
Reviewed-by: Kerri Hendrix <kerri@dev.com>
Acked-by: Tom Monson <joe@dev.com>
Signed-off-by: Sadie Wu <sadie@dev.com>
```

## For maintainers

### Branches

Work in `<type>/<issue>-<description>` branches, such as `feat/14-add-schema`.
Branches will be deleted after merging.
Tie pull requests to exactly 1 issue, if appropriate.

If work directly on _main_ or another permanent branch is necessary,
configure Git to use your GPG key and run `git commit` with `-S`.

### Issues

Issues to be worked on must have exactly 1 `type:` label,
and they must have the label `status: ready for dev`.
Use `effort:` and `priority:` labels where helpful.

Split large issues into bit-sized pieces and list those in the larger issue’s description.

!!! example

```markdown
Requires several steps:

- [x] [write schema](#21)
- [x] [build schema linter](#22)
- [ ] [create infrastructure to deploy schema](#23)
```

### Reviewing and accepting pull requests

Please do not submit a review until the required status checks completed successfully.
Before that, you can add comments.

### Accepting pull requests

When accepting pull requests, use either technique:

- Squash all commits into a single commit **(most cases)**.
  The commit subject should be the pull request title; edit the title if necessary.
- Rebase with all commits after ensuring that the messages conform to standards.

To help a contributor with their PR directly, see
["Committing changes to a pull request branch created from a fork"](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/committing-changes-to-a-pull-request-branch-created-from-a-fork).
If the contributor abandoned the PR, instead use `gh pr checkout <number>`.

### Deploying & versioning

To automatically bump the version and deploy, run the _Deploy_ workflow on GitHub.
Make sure tests passed on the main branch before doing this.

Versioning is a subset of [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Pre-releases are permitted only in the forms `alpha<int>`, `beta<int>`, and `rc<int>`,
where `<int>` starts at `0`. Alpha/beta/RC MUST NOT be used out of order (e.g., **not** `alpha1`, `beta1`, `alpha2`).

### Copyright headers

Ensure that nontrivial files contain a header:

```text
SPDX-FileCopyrightText: Copyright <years>, Contributors to <project>
SPDX-PackageHomePage: <url>
SPDX-License-Identifier: <spdx-id>
```

!!! example
For [Tyranno](https://github.com/dmyersturnbull/tyrannosaurus), this is:

```text
SPDX-FileCopyrightText: Copyright 2020-2023, Contributors to CICD
SPDX-PackageHomePage: https://github.com/dmyersturnbull/tyranno
SPDX-License-Identifier: Apache-2.0
```
