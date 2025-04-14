# Commit messages

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

### Conventional commit messages

Commit messages must follow a subset of [Conventional Commits](https://www.conventionalcommits.org/).
Types are from [PyData’s contributing guide](https://sparse.pydata.org/en/latest/contributing/#contributing-code).

## Example

```text
feat(api)!: add major new feature

Introduces an option to set a **custom template**.

Defines the template parameters:
- name
- status
- description

BREAKING CHANGE: /api/v1/generate-report endpoint

Closes #14
Reverts: 2a0f4f2
Deprecates: /api/v1/generate-report endpoint
Co-authored-by: Amelia Johnson <amelia@dev.com>
Co-authored-by: Cecilia Johnson <cecilia@dev.com>
Reviewed-by: Kerri Hendrix <kerri@dev.com>
Acked-by: Tom Monson
Signed-off-by: Sadie Wu <sadie@dev.com>
```

## Approximate pattern

```text
<type>[(<scope>)][!]: <subject>

<body>

[BREAKING CHANGE: <feature, etc.>]

[Closes #<issue>]
[Deprecates: <feature, etc.>]
[Reverts: <commit hash>]
[<trailer>: <author>]*
"""
```

## Regular expression

```regexp
(?<type> feat|fix|docs|style|refactor|perf|test|drop|depr|ci|build )
(?: \( (?<scope> [a-z]++(?:-[a-z]++)*+ ) \) )?+
(?<is_breaking> ! )?+
:\u0020
(?<subject> \S[\S\u0020]*+ )

(?<body>
(?: \n\n (?: \S[\S\u0020]*+ | \n(?!\n) )++ )*?
)??

(?:
\n\nBREAKING\u0020CHANGE:\u0020
(?<breaks> \S[\S\u0020]*+ )
)?

(?>
\n
(?>
\nCloses \u0020# (?<closes> \d++ )
|
\nReverts :\u0020 (?<reverts> [a-f0-9]{12} )
|
\nDeprecates :\u0020 (?<deprecates> \S[\S\u0020]*+ )
|
\n(?<key> [^\s:]++) (?:\u0020|\u0020#) (?<value> \S[\S\u0020]*+ )
)*+
)?+
```

### Additional requirements

- **Breaking changes:** Breaking changes MUST be indicated by `!`.
  If a body is present, a single `BREAKING CHANGE:` footer must list the changed feature(s).
- **Body:** The body SHOULD be written as CommonMark.
  The subject SHOULD be assumed to be an implicit level 3 (`###`) heading;
  headings used SHOULD be limited to levels 4 and 5.
  Present tense is RECOMMENDED (e.g. `Fixes` rather than `Fix`).
- **Footers:** Commits MUST NOT use footers that have not been defined.
  The footers that are defined in this document are
  `BREAKING CHANGE`, `Deprecates`, `Closes`, and the attribution trailers listed below.
  Projects MAY define additional trailers, which MUST match `key: value` or `key #value`.
  Keys SHOULD match `[A-Z][A-Za-z0-9]*+(?:-[A-Za-z0-9]++)*+`.

### Attribution trailers

These attribution trailers are allowed:

- Acked-by
- Reviewed-by
- Helped-by
- Reported-by
- Mentored-by
- Suggested-by
- CC
- Noticed-by
- Tested-by
- Improved-by
- Thanks-to
- Based-on-patch-by
- Contributions-by
- Co-authored-by
- Requested-by
- Original-patch-by
- Inspired-by
- Signed-off-by

This regex MAY be used to parse attribution trailers:

```regexp
(?<key> [A-Z][A-Za-z]*+(?:-[a-z]++)*+)
\u0020
(?<author> [^\s<>](?:[^\s<>]|\u0020)+(?!\u0020) )
\u0020
< (?<email>[\w.+-]++@[\w.-]++\.[a-z]++) >
```
