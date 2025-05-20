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

<b>Types:</b>

| Type      | Description (with no scope)              | Bump  | Section       |
| --------- | ---------------------------------------- | ----- | ------------- |
| add       | a new feature                            | minor | New features  |
| change    | an existing feature                      | major | Changes       |
| remove    | an existing feature                      | major | Removals      |
| end       | support for something 3rd-party          | major | Removals      |
| deprecate | functionality                            | minor | Deprecations  |
| fix       | a regular bug                            | patch | Bug fixes     |
| patch     | a vulnerability                          | patch | Security      |
| optimize  | performance                              | patch | Performance   |
| update    | pinned dependencies                      | patch | Dependencies  |
| document  | a feature, concept, etc.                 | none  | Documentation |
| correct   | an error in documentation                | none  | Documentation |
| refactor  | code, etc., without affecting behavior   | none  | Internal      |
| format    | code, configuration, etc.                | none  | (none)        |
| release   | a new version (after bumping the number) | none  | (none)        |

<b>Key scopes:</b>

| Scope       | Description                                | Bump      | Section       |
| ----------- | ------------------------------------------ | --------- | ------------- |
| build       | Makefiles, etc.                            | no change | Build changes |
| tests       | Test cases                                 | no        | Internal      |
| infra       | Structure, scripts, internal docs, etc.    | no        | Internal      |
| infra/tests | Organization, fixtures, etc.               | no        | Internal      |
| infra/cicd  | CI/CD pipelines                            | no        | Internal      |
| infra/docs  | Organization, scripts, configuration, etc. | no        | Internal      |
| i18n        | Internationalization                       | no change | Miscellaneous |
| a11y        | Accessibility                              | no change | Miscellaneous |
| mention:on  | Include in release notes                   | no change | Miscellaneous |
| mention:off | Exclude from release notes                 | no change | (exclude)     |

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
