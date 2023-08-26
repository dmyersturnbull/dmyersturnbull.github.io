# Maintainers' guide

!!! abstract "How to use these docs"
    These docs are meant to be linked to.
    Include a link in your project's readme or _CONTRIBUTING.md_.
    E.g.,
    ```markdown
    See https://dmyersturnbull.github.io/ref/maintainer-guide/
    but disregard the `security:` commit type.
    ```

    Or just link to individual sections; e.g.,
    ```markdown
    Source headers: Please refer to https://dmyersturnbull.github.io/ref/maintainer-guide/#source-headers
    ```

This guide contains a collection of best-practices.
They tend to be easy to learn, easy to use, and easy to automate.
They work with a range of CI/CD workflows and various automation tools.
More notably, they are sufficient to get a transparent 1-1-1-1-1 mapping between
issues, feature branches, pull requests, main branch commits, and changelog entries.

## Branches

Use [GitLab Flow](https://about.gitlab.com/topics/version-control/what-is-gitlab-flow/)
/ [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow).
Name feature branches `<type>/<issue>-<description>`, such as `feat/14-add-schema`.
Each must be tied to exactly 1 issue and result in 1 merge to _main_.
If used, stable release branches must be named `releases/<vr>`; e.g., `releases/v1`.

## Issues

Issues to be worked on must have exactly 1 `type:` label, and they must have the label `status: ready for dev`.
Use `effort:` and `priority:` labels where helpful.

Split large issues into bit-sized pieces and list those in the larger issue’s description.

!!! example

    ```markdown
    Requires several steps:

    - [x] [write schema](#21)
    - [x] [build schema linter](#22)
    - [ ] [create infrastructure to deploy schema](#23)
    ```

## Handling pull requests

Do not submit a review until the required status checks completed successfully.
(You can add comments before this.)

When accepting pull requests, use either technique:

- Squash all commits into one **(most cases)**.
  The commit subject should be the pull request title; edit the title if necessary.
- Rebase all commits after ensuring that the messages conform to standards.

To help a contributor with their PR directly, see
["Committing changes to a pull request branch created from a fork"](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/committing-changes-to-a-pull-request-branch-created-from-a-fork).
If the contributor abandoned the PR, instead use `gh pr checkout <number>`.

## Versioning

Versioning is a subset of [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Pre-releases are permitted only in the forms `alpha<int>`, `beta<int>`, and `rc<int>`,
where `<int>` starts at 0. Alpha/beta/RC MUST NOT be used out of order (e.g., **not** `alpha1`, `beta1`, `alpha2`).

## Tags and deployment

Tags of the form `v<semver>` should result in full deployments.
Tags of the form `v<major>` should automatically track their most recent semver tags.
The `latest` tag should always match the main branch.

Deploy off of the main branch or tags.
Make sure tests passed on the main branch before deploying.

## Source headers

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

## 3rd-party code

Use SPDX headers in the aforementioned form.
Include a section in `NOTICE.txt` mentioning the source file(s), license, and external source.
Include the license file in the form `LICENSE-<spdx-id>.txt`.

## Commit messages and changelog

We follow [Conventional Commits](https://www.conventionalcommits.org/) using the following types.
The general pattern for the subject is `<type>[(<scope>)][!]: <subject>`,
where `(<scope>)` is empty, `plugins`, or `i18n`; and `!` denotes a breaking change.

!!! example
    ```text
    feat!: add schema
    ```
    ```text
    doc(i18n): add JP translation
    ```

This table shows how commit messages map to issue labels and changelog sections.

| Type        | Label               | Changelog section  | semver | Description                               |
|-------------|---------------------|--------------------|--------|-------------------------------------------|
| `security:` | `type: security`    | `🔒 Security`      | minor  | Fix a security issue                      |
| `feat:`     | `type: feature`     | `✨ Features`       | minor  | Add or change a feature                   |
| `fix:`      | `type: fix`         | `🐛 Bug fixes`     | patch  | Fix a bug                                 |
| `docs:`     | `type: docs`        | `📝 Documentation` | patch  | Modify docs or examples                   |
| `build:`    | `type: build`       | `🔧 Build system`  | minor  | Modify build                              |
| `perf:`     | `type: performance` | `⚡️ Performance`   | patch  | Increase speed or decrease resource usage |
| `test:`     | `type: test`        | `🚨 Tests`         | N/A    | Add or modify tests                       |
| `ci:`       | `type: ci`          | ignored            | N/A    | Modify CI/CD                              |
| `refactor:` | `type: refactor`    | ignored            | N/A    | Refactor source code                      |
| `style:`    | `type: style`       | ignored            | N/A    | Modify code style                         |
| `chore:`    | `type: chore`       | ignored            | N/A    | Change non-source code                    |

## Reference

!!! details "Full pattern"

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
