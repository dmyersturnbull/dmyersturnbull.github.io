---
tags:
  - DevOps
  - Git
  - GitHub
---

# Issue labels (supplemental)

<!--
SPDX-FileCopyrightText: Copyright 2017-2026, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This is a set of issue labels intended to complement the
[contributor guide](contributor-guide.md).
They are used in the
[tyranno-sandbox repo](https://github.com/dmyersturnbull/tyranno-sandbox).

!!! abstract "To use in your projects"

    Link to https://dmyersturnbull.github.io/ref/contributor-guide/.
    Refer to that guide for information.
    To add these to GitHub programmatically, refer to
    [tyranno-sandbox repo](https://github.com/dmyersturnbull/tyranno-sandbox).

!!! abstract "Another way to use"

    Feel free to use some or all of these labels in your project.
    No need to credit me for that.
    (If you’re writing your own recommendations for other projects to use
    (e.g. on your blog), please do credit.)

## Groups

Labels are organized into are 8 groups.

- `type` **(mandatory)**: The kind of changes (matches commit types)
- `breaking` **(mandatory)**: Whether breaking changes are needed (in issues) or made (in PRs)
- changelog overrides: `changelog: include` and `changelog: exclude`
- `priority`: The importance and urgency
- `state`: What type of work needs to be done (development work is just 1 type)
- `effort`: How much work it requires
- `scope`: The component (matches commit scopes)
- miscellaneous:
  `question` (for user questions in issues),
  `help needed` (to request help),
  and `bookmark` (for issues that contain important information)

## Table

| Label                       | Commit part    | Changelog section   | Bump  | Icon | Description                  | Color     |
| --------------------------- | -------------- | ------------------- | ----- | ---- | ---------------------------- | --------- |
| `breaking`                  | `!`            | 💥 Breaking changes | major | 💥   | Breaking change              | `000000`  |
| `changelog: exclude`        | N/A            | N/A                 | N/A   | 🔕   | Always omit from changelog   | `f2e9e9`  |
| `changelog: include`        | N/A            | N/A                 | N/A   | 🔔   | Always include in changelog  | `f9e6e6`  |
| `effort: 1-easy`            | N/A            | N/A                 | N/A   | 1️⃣   | Easy (t < 1 hr)              | `50b0ff`  |
| `effort: 2-moderate`        | N/A            | N/A                 | N/A   | 2️⃣   | Moderate (1 hr <= t < 4 hr)  | `90e0fff` |
| `effort: 3-difficult`       | N/A            | N/A                 | N/A   | 3️⃣️  | Hard (>= 4 hours)            | `8670ff`  |
| `effort: 4-multipart`       | N/A            | N/A                 | N/A   | #️⃣   | References multiple issues   | `c050ff`  |
| `help needed`               | N/A            | N/A                 | N/A   | 👋   | Help needed                  | `50ff50`  |
| `priority: 1-low`           | N/A            | N/A                 | N/A   | 🟩   | No need to rush              | `99dd00`  |
| `priority: 2-medium`        | N/A            | N/A                 | N/A   | 🟨   | Not blocking but important   | `d0cc11`  |
| `priority: 3-high`          | N/A            | N/A                 | N/A   | 🟧   | Blocks a release             | `e09911`  |
| `priority: 4-critical`      | N/A            | N/A                 | N/A   | 🟥   | Must be fixed ASAP           | `ff6600`  |
| `question`                  | N/A            | N/A                 | N/A   | 💬   | User question (issues only)  | `8800ff`  |
| `scope: dev-infra`          | `(dev-infra)`  | N/A                 | N/A   | 🛠   | Dev infrastructure           | `009000`  |
| `scope: docs-infra`         | `(docs-infra)` | N/A                 | N/A   | 🛠   | Docs infrastructure          | `009000`  |
| `scope: i18n` (optional)    | `(i18n)`       | N/A                 | N/A   | 🌐   | Internationalization         | `009000`  |
| `scope: plugins` (optional) | `(plugins)`    | N/A                 | N/A   | 🧩   | Plugins                      | `000090`  |
| `state: awaiting triage`    | N/A            | N/A                 | N/A   | 🚦   | Awaiting triage              | `f0f0f0`  |
| `state: blocked`            | N/A            | N/A                 | N/A   | 🚧   | Blocked by another issue     | `e0e0e0`  |
| `state: needs details`      | N/A            | N/A                 | N/A   | 🏷️   | Needs more details           | `f0f0f0`  |
| `state: ready for dev`      | N/A            | N/A                 | N/A   | 🏁   | Ready for work               | `e0e0e0`  |
| `state: rejected`           | N/A            | N/A                 | N/A   | ✖️   | Will not be worked on        | `ffffff`  |
| `sticky`                    | N/A            | N/A                 | N/A   | 🔖   | Important for reference      | `ffff44`  |
| `type: build`               | `build:`       | 🔧 Build system     | minor | 🔧   | Modify build or dependencies | `90e0ff`  |
| `type: chore` †             | `chore:`       | skipped             | none  | 🧹   | Other type of change         | `90e0ff`  |
| `type: cicd`                | `ci:`          | 🍒 Miscellaneous    | none  | ⚙️   | Modify CI/CD                 | `90e0ff`  |
| `type: deprecation`         | `depr:`        | 🗑️ Deprecations     | minor | 🗑️   | Deprecate something public   | `90e0ff`  |
| `type: docs`                | `docs:`        | 📝 Documentation    | patch | 📝   | Modify docs or examples      | `90e0ff`  |
| `type: drop`                | `drop:`        | 💥 Breaking changes | major | ❌   | Remove a feature             | `90e0ff`  |
| `type: feature`             | `feat:`        | ✨ Features         | minor | ✨   | Add or modify a feature      | `90e0ff`  |
| `type: fix`                 | `fix:`         | 🐛 Bug fixes        | patch | 🐛   | Fix a bug                    | `90e0ff`  |
| `type: performance`         | `perf:`        | ⚡️ Performance     | patch | ⚡️  | Reduce resource usage        | `90e0ff`  |
| `type: refactor`            | `refactor:`    | 🍒 Miscellaneous    | none  | ♻️   | Refactor source code         | `90e0ff`  |
| `type: security`            | `security:`    | 🔒️ Security        | minor | 🔒️  | Fix vulnerability or harden  | `90e0ff`  |
| `type: style`               | `style:`       | skipped             | none  | 🎨   | Modify code style            | `90e0ff`  |
| `type: test`                | `test:`        | 🍒 Miscellaneous    | none  | 🚨   | Add or modify tests          | `90e0ff`  |

/// table-caption
<b>Issue/PR labels with associated commit types.</b>
///

??? question "Rationale"

    Requirements met:

    - The types are simply a superset of the current
      [Angular commit types](https://github.com/angular/angular/blob/main/CONTRIBUTING.md)
      and other commonly used sets, including
      [Angular’s earlier revisions](#angular-commit-type-revisions).
    - Commit messages can be used to generate useful, complete, and obvious changelog.
    - Labels have obvious names and are grouped.

    As a bonus, the symbols are compatible with [Gitmoji](https://gitmoji.dev/).

## Supplemental

### Other issue label sets

- [Creative Commons](https://opensource.creativecommons.org/contributing-code/repo-labels/)
- [Gitmoji](https://gitmoji.dev/)
- [Sean Trane’s labels](https://seantrane.com/posts/logical-colorful-github-labels-18230/)
- [Conventional changelog metahub](https://github.com/pvdlg/conventional-changelog-metahub)

### Angular commit type revisions

- [7aea525](https://github.com/angular/angular/commit/7aea5256de55056e424f9c6d92ac1d6f38d3abee)
  in 2021 added `DEPRECATED`
- [c1bc070](https://github.com/angular/angular/commit/c1bc070b40e0658ffd35f0543fa0255d090bcb02)
  removed `style:`.
- [dff6ee3](https://github.com/angular/angular/commit/dff6ee32725197bdb81f3f63c5bd9805f2ed22bb)
  in 2017 removed `chore:`.
