---
tags:
  - Git
  - GitHub
  - BNF
---

# Non-conventional commits

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

<b>Spec status: draft; not usable.</b>

There are significant well-recognized problems with Conventional Commits.
This nascent specification simply explores alternatives.

!!! related

    - [Restricted conventional commits spec](commit-messages.md).

| Phrase     | Syntax (prefix)       | Description                     | Group | Bump  | Section         |
|------------|-----------------------|---------------------------------|-------|-------|-----------------|
| modify     | `modify {T} {X}: {s}` | behavior in public API          | main  | major | `Changes`       |
| move       | `move {T} {A} to {B}` | a part of the public API        | main  | major | `Changes`       |
| remove     | `remove {T} {A}`      | a feature, endpoint, etc.       | main  | major | `Removals`      |
| change     | `change {what}`       | and break the install process   | build | major | `Install`       |
| drop       | `drop {T} {X}`        | a platform, etc.                | build | major | `Platforms`     |
| support    | `support {ST} {X}`    | a platform, etc.                | build | minor | `Platforms`     |
| introduce  | `introduce {ST} {X}`  | a new feature                   | main  | minor | `New features`  |
| deprecate  | `deprecate {ST} {X}`  | a feature                       | main  | minor | `Deprecations`  |
| fix        | `fix {T} {X} #{I}`    | a non-security bug              | main  | patch | `Bug fixes`     |
| patch      | `patch {T} {X} #{I}`  | a vulnerability                 | main  | patch | `Security`      |
| optimize   | `optimize {T} {X}`    | performance                     | main  | patch | `Performance`   |
| update     | `update {realm}`      | pinned dependencies             | main  | patch | `Dependencies`  |
| write      | `write {doc}`         | a new documentation file        | docs  | -     | `Documentation` |
| revise     | `revise {doc}`        | existing documentation          | docs  | -     | `Documentation` |
| correct    | `correct {doc}`       | mistake(s) in docs              | docs  | -     | `Documentation` |
| add        | `add {TT} {X}`        | some test(s)                    | tests | -     | `Internal`      |
| repair     | `repair {TT} {X}`     | broken test(s)                  | tests | -     | `Internal`      |
| refactor   | `refactor {X}`        | code without affecting behavior | main  | -     | `Internal`      |
| reorganize | `reorganize {files}`  | files (not just code)           | infra | -     | `Internal`      |
| format     | `format {files}`      | files to improve style          | N/A   | -     | -               |
| release    | `release {tag}`       | a new version                   | N/A   | -     | -               |

/// table-caption
<b>Change phrases</b>

- `T` – type; `feature | endpoint | command | API | class | method | function | ...`
- `ST` – support type; `platform | {tool} version | ...`
- `TT` – test type; normally `test` (but values like `integration test` could be defined)
- `X`, `A`, `B` – names, endpoints, paths, packages, systems, platforms, etc.
- `what` – what was changed; perhaps `install`, `project name`, etc.
- `I` – issue/ticket: number
- `realm` – group of pinned dependencies; `dev deps | `
- `doc` – document file
- `files` – a short phrase, directory, or filename
- `tag` – a semver version prefixed with `v`
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
