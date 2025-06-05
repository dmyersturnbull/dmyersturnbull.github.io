# Non-conventional commits

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

There are significant well-recognized problems with Conventional Commits.
This nascent specification simply explores alternatives.

!!! related

    - [Restricted conventional commits spec](conventional-commits.md).

| Type         | Category | Description                     | Bump      | Section         |
| ------------ | -------- | ------------------------------- | --------- | --------------- |
| replace      | main     | a feature with another          | **major** | `Changes`       |
| change       | main     | the behavior in public API      | **major** | `Changes`       |
| rename       | main     | a part of the public API        | **major** | `Changes`       |
| remove       | main     | a feature                       | **major** | `Removals`      |
| modify build | build    | or install in a breaking way    | **major** | `Build/install` |
| end support  | build    | for a platform, etc.            | **major** | `Platforms`     |
| add support  | build    | for a platform, etc.            | minor     | `Platforms`     |
| introduce    | main     | a new feature                   | minor     | `New features`  |
| deprecate    | main     | a feature                       | minor     | `Deprecations`  |
| fix          | main     | a non-security bug              | patch     | `Bug fixes`     |
| patch        | main     | a vulnerability                 | patch     | `Security`      |
| optimize     | main     | performance                     | patch     | `Performance`   |
| update       | main     | pinned dependencies             | patch     | `Dependencies`  |
| document     | docs     | a feature, concept, etc.        | -         | `Documentation` |
| revise       | docs     | existing documentation          | -         | `Documentation` |
| correct      | docs     | a mistake in docs               | -         | `Documentation` |
| cover        | tests    | some behavior with tests        | -         | `Internal`      |
| repair       | tests    | a broken test                   | -         | `Internal`      |
| refactor     | main     | code without affecting behavior | -         | `Internal`      |
| reorganize   | infra/\* | files (not just code)           | -         | `Internal`      |
| format       | -        | files to improve style          | -         | -               |
| release      | -        | a new version (bumping it)      | -         | -               |

/// table-caption
<b>Change types, assuming no scope applies</b>
///

| Tag / scope   | Description                    | Bump      | Section    |
| ------------- | ------------------------------ | --------- | ---------- |
| <b>Tags</b>   | <b>―</b>                       | <b>―</b>  | <b>―</b>   |
| `infra/build` | Makefiles, file layout, etc.   | ≤ patch   | `Internal` |
| `infra/dev`   | Developer tools (e.g. scripts) | 🚫        | `Internal` |
| `infra/tests` | E.g. test fixtures             | 🚫        | `Internal` |
| `infra/cicd`  | CI/CD pipelines                | 🚫        | `Internal` |
| `infra/docs`  | E.g. config                    | 🚫        | `Internal` |
| `trivial`     | Ignore in versioning and notes | 🚫        | 🚫         |
| `breaking`    | Treat as a breaking change     | major     | no effect  |
| `minor`       | Treat as a minor change        | minor     | no effect  |
| `patch`       | Treat as a patch change        | patch     | no effect  |
| `section={x}` | Override release notes section | no effect | _{x}_      |
| `wip`         | Work in progress (don’t merge) | N/A       | N/A        |
| <b>Scopes</b> | <b>―</b>                       | <b>―</b>  | <b>―</b>   |
| `i18n`        | Internationalization           | ≤ patch   | icon       |
| `a11y`        | Accessibility                  | ≤ patch   | icon       |

/// table-caption
<b>Tags/scopes, with associated changes to versioning and release notes</b>
///

Then you could use the type as part of the subject and better distinguish kinds of changes.
For example:

<b>Commit history:</b>

```text
patch(infra/docs) XSS vulnerability in docs playground tool
remove! v1 API endpoints
end! support for macOS Yosemite
correct typo in intro
refactor(infra) developer utility scripts
add(i18n) Japanese translation
add endpoint to compare structures
```

<b>Release notes:</b>

```markdown
## v1.2.0 – 2025-05-07T14:12:35Z

### New features

- Added endpoint to compare structures (PR #11)

### Removals

- Removed v1 API endpoints (PR #12)
- Ended support for macOS Yosemite (PR #13)

### Miscellaneous

- Added Japanese translation (PR #10)

### Internal

- Patched XSS vulnerability (PR #15)
- Refactored developer utility scripts (PR #22)
```
