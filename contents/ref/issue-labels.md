<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Issue labels

This is a set of issue labels intended to complement the [contributor guide](contributor-guide.md).
They are used in the [CICD repo](https://github.com/dmyersturnbull/cicd).

!!! info "To use in your projects"

    Link to https://dmyersturnbull.github.io/ref/contributor-guide/.
    Refer to that guide for information.
    To add these to GitHub programmatically, refer to [CICD](https://github.com/dmyersturnbull/cicd).

!!! info "Another way to use"

    Feel free to use some or all of these labels in your project.
    No need to credit me for that.
    (If you’re writing your own recommendations for other projects to use
    (e.g. on your blog), please do credit.)

There are 6 groups:

- `type`: The kind of changes (matches commit types)
- `priority`: The importance and urgency
- `state`: What type of work needs to be done (development work is just 1 type)
- `effort`: How much work it requires
- `scope`: The component (matches commit scopes)
- `breaking`: Whether breaking changes are required (for issues) or made (for PRs)
- changelog overrides:
  `changelog: include` (always list in the changelog under _🍒 Miscellaneous_),
  and `changelog: exclude` (never list in the changelog)
- optional miscellaneous labels: `help needed` (to request help)
  and `bookmark` (for issues that contain important information)

`type` is required for both issues and PRs.
The `type` of a PR should match its commit type when squashed.
`priority`, `effort`, and `scope` should be used when they are helpful.

## Table

| Label                    | Commit part | Changelog section   | Bump  | Icon | Description                     | Color     |
| ------------------------ | ----------- | ------------------- | ----- | ---- | ------------------------------- | --------- |
| `bookmark` (optional)    | N/A         | N/A                 | N/A   | 🔖   | Important for reference         | `ffff44`  |
| `breaking`               | `!`         | 💥 Breaking changes | major | 💥   | Breaking change                 | `000000`  |
| `changelog: exclude`     | N/A         | N/A                 | N/A   | 🔕   | Always omit from changelog      | `f2e9e9`  |
| `changelog: include`     | N/A         | N/A                 | N/A   | 🔔   | Always include in changelog     | `f9e6e6`  |
| `effort: 1-easy`         | N/A         | N/A                 | N/A   | 1️⃣   | Easy (t < 1 hr)                 | `50b0ff`  |
| `effort: 2-moderate`     | N/A         | N/A                 | N/A   | 2️⃣   | Moderate (1 hr <= t < 4 hr)     | `90e0fff` |
| `effort: 3-difficult`    | N/A         | N/A                 | N/A   | 3️⃣️  | Hard (>= 4 hours)               | `8670ff`  |
| `effort: 4-multipart`    | N/A         | N/A                 | N/A   | #️⃣   | References multiple issues      | `c050ff`  |
| `help needed` (optional) | N/A         | N/A                 | N/A   | 👋   | Help needed                     | `50ff50`  |
| `priority: 1-low`        | N/A         | N/A                 | N/A   | 🟩   | No need to rush                 | `99dd00`  |
| `priority: 2-medium`     | N/A         | N/A                 | N/A   | 🟨   | Not blocking but important      | `d0cc11`  |
| `priority: 3-high`       | N/A         | N/A                 | N/A   | 🟧   | Blocks a release                | `e09911`  |
| `priority: 4-critical`   | N/A         | N/A                 | N/A   | 🟥   | Must be fixed ASAP              | `ff6600`  |
| `scope: i18n` (e.g.)     | `(i18n)`    | N/A                 | N/A   | 🌐   | Relates to internationalization | `009000`  |
| `scope: plugins` (e.g.)  | `(plugins)` | N/A                 | N/A   | 🧩   | Relates to plugins              | `000090`  |
| `state: awaiting triage` | N/A         | N/A                 | N/A   | 🚦   | Awaiting triage                 | `f0f0f0`  |
| `state: blocked`         | N/A         | N/A                 | N/A   | 🚧   | Blocked by another issue        | `e0e0e0`  |
| `state: needs details`   | N/A         | N/A                 | N/A   | 🏷️   | Needs more details              | `f0f0f0`  |
| `state: ready for dev`   | N/A         | N/A                 | N/A   | 🏁   | Ready for work                  | `e0e0e0`  |
| `state: rejected`        | N/A         | N/A                 | N/A   | ✖️   | Will not be worked on           | `ffffff`  |
| `type: build`            | `build:`    | 🔧 Build system     | minor | 🔧   | Modify build or dependencies    | `90e0ff`  |
| `type: cicd`             | `ci:`       | 🍒 Miscellaneous    | none  | ⚙️   | Modify CI/CD                    | `90e0ff`  |
| `type: deprecation`      | `depr:`     | 🗑️ Deprecations     | minor | 🗑️   | Deprecate something public      | `90e0ff`  |
| `type: docs`             | `docs:`     | 📝 Documentation    | patch | 📝   | Modify docs or examples         | `90e0ff`  |
| `type: drop`             | `drop:`     | 💥 Breaking changes | major | ❌   | Remove a feature                | `90e0ff`  |
| `type: feature`          | `feat:`     | ✨ Features         | minor | ✨   | Add or modify a feature         | `90e0ff`  |
| `type: fix`              | `fix:`      | 🐛 Bug fixes        | patch | 🐛   | Fix a bug                       | `90e0ff`  |
| `type: performance`      | `perf:`     | ⚡️ Performance     | patch | ⚡️  | Reduce resource usage           | `90e0ff`  |
| `type: refactor`         | `refactor:` | 🍒 Miscellaneous    | none  | ♻️   | Refactor source code            | `90e0ff`  |
| `type: security`         | `security:` | 🔒️ Security        | minor | 🔒️  | Fix vulnerability or harden     | `90e0ff`  |
| `type: style`            | `style:`    | skipped             | none  | 🎨   | Modify code style               | `90e0ff`  |
| `type: test`             | `test:`     | 🍒 Miscellaneous    | none  | 🚨   | Add or modify tests             | `90e0ff`  |
| N/A                      | `release:`  | skipped             | N/A   | ✉️   | Bump the version and deploy     | N/A       |

!!! rationale

    This meets my two requirements:

    - It’s compatible with up-to-date
      [Angular commit types](https://github.com/angular/angular/blob/main/CONTRIBUTING.md).
    - Commit messages can be used to generate useful, complete, and obvious changelog.

    And has some nice-to-have features:

    - It is consistent with [Gitmoji](https://gitmoji.dev/).
      (_Exception:_ Gitmoji uses 🔊 and 🔇 for commits that modify logs.)
    - It prefers terms that are commonly used in the wild, such as _effort_ and _priority_.
    - Labels are grouped in an obvious way.
    - Labels have obvious names and are easy to type.

    **References:**

    - [Creative Commons](https://opensource.creativecommons.org/contributing-code/repo-labels/)
    - [Gitmoji](https://gitmoji.dev/)
    - [Sean Trane’s labels](https://seantrane.com/posts/logical-colorful-github-labels-18230/)
    - [Conventional changelog metahub](https://github.com/pvdlg/conventional-changelog-metahub)
