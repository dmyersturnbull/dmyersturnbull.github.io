# Conventional commits

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Abstract

!!! related

    - [“Non-conventional commits” spec](non-conventional-commits.md).

This document covers a single specification for structured Git commit messages.
There are two aspects:

### A “profile” of [Conventional Commits](https://www.conventionalcommits.org/)

The profile is based on the
[Angular guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md),
[PyData’s contributing guide](https://sparse.pydata.org/en/latest/contributing/#contributing-code),
and [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional).
Types, general scopes, and footers are defined.
Projects should derive from this spec, defining their own scopes.

### A normalized form of Conventional Commits

Conventional Commits is partly ambiguous, inconsistent, and overly flexible.
We specify an unambiguous grammar, exact terminology, and additional requirements.
Most importantly, this enables simple and reliable parsing.

## Definitions

The key words _MUST_, _MUST NOT_, _REQUIRED_, _SHALL_, _SHALL NOT_,
_SHOULD_, _SHOULD NOT_, _RECOMMENDED_, _MAY_, and _OPTIONAL_ in this
document are to be interpreted as described in
[RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

## Example

<b>Commit 1:</b>

```text
depr(api): deprecate v1 api

Deprecates V1 API in favor of V2.
Clients are encouraged to use V2, which is a superset of V1.
New features are described in the [V2 API announcement](https://amazing-api.dev#v2).

DEPRECATED: `/api/v1/` endpoints (use `/api/v2/` instead)

Closes #12
Co-authored-by: Amelia Johnson <amelia@dev.com>
Co-authored-by: Cecilia Johnson <cecilia@dev.com>
```

<b>Commit 2:</b>

```text
drop(api)!: drop v1 api

Removes V1 API endpoints, as discussed in the [V2 API announcement](https://amazing-api.dev#v2).
See also: [issue #12](https://github.com/amazing-api/apiz/issues/12).

BREAKING CHANGE: `/api/v1/` endpoints (removed)

Closes #24
Reviewed-by: Tom Thompson <tom@hotmail.net>
```

<b>Commit 3:</b>

```text
fix(api): re-add v1 api

This commit reverts 2a0f4f2.
Re-adds the V1 API, which was removed ahead of schedule.
Also removed Tom Thompson from the contributor list.

Reported-by: Isaac Malone <isaac.malone@gmail.com>
CC: Amelia Johnson <amelia@dev.com>
```

## Approximate pattern

```text
<type>[(<scope>)][!]: <subject>

[This commit reverts <commit hash>.]
<body>

[BREAKING CHANGE: <feature, etc.> [\n\n<how to migrate, etc.>] ]

[DEPRECATED: <feature, etc.> [\n\n<how to migrate, etc.>] ]

[Closes #<issue>]
[<trailer>: <author>]*
"""
```

## Specification

### Core grammar

```regexp
(?<type> feat|fix|security|docs|style|refactor|perf|test|drop|depr|ci|build|chore )
(?: \( (?<scopes> ([a-z]++(?:-[a-z]++)*+)(,([a-z]++(?:-[a-z]++)*+))*+ ) \) )?+
(?<is_breaking> ! )?+
:\u0020
(?<subject> \S[\S\u0020]*+ )

(?:
\n\nThis commit reverts (?<reverts> [0-9a-f]{7}(?:, [0-9a-f]{7})++ ).
)?+
(?<body>
(?: \n{2}? (?: \S[\S\u0020]*+ | \n(?!\n) )++ )*?
)??

(?:
\n\nBREAKING\u0020CHANGE:\u0020
(?<breaking_change> \S[\S\u0020]*+ )
)?

(?:
\n\nDEPRECATED:\u0020
(?<deprecated> \S[\S\u0020]*+ )
)?

(?>
\n
(?>
\nCloses \u0020# (?<closes> \d++ )
|
\n(?<key> [^\s:]++) (?:\u0020|\u0020#) (?<value> \S[\S\u0020]*+ )
)*+
)?+
```

### Additional requirements

#### Subject

As specified by Conventional Commits, the subject SHOULD
use imperative mood and present tense,
contain only 1 (incomplete) sentence,
start with a verb,
not mark the end with `.`,
and describe the **change made** by the commit (**not** the behavior of the code).

!!! info "Important"

    > The description is a short summary of the code changes; e.g.:
    > `fix: array parsing issue when multiple spaces were contained in string`

    ❌ Incorrect: `fix: raise error when config is missing`

    ✅ Correct: `fix:

#### Scopes

Projects are encouraged to define their own scopes.

In addition, they should use either the scopes `dev-infra` and `docs-infra` as defined by the
[Angular commit message guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md#-scope)
OR one or more scopes that serve similar purposes.
In particular, projects should consider how scopes can be used to organize release notes
and to exclude changes from release notes or changelogs.

#### Breaking changes

Breaking changes MUST be indicated by `!`.
If a body is present, a single `BREAKING CHANGE:` footer MUST list the changed feature(s).

#### Body

The body SHOULD be written as CommonMark.
The subject SHOULD be assumed to be an implicit level 3 (`###`) heading;
headings used SHOULD be limited to levels 4 and 5.
Present tense is RECOMMENDED (e.g. `Fixes` rather than `Fix`).

##### _Special body paragraphs_

Git trailer format does not permit blank lines between trailers,
and it does not allow spaces in trailer keys.
This document considers `BREAKING CHANGE` and `DEPRECATES` to be part of the body,
which we will formally call _special body paragraphs_.
Both special body paragraphs MUST be below any normal body paragraphs,
and `BREAKING CHANGE` MUST be listed first if both are present.

#### True footers (trailers)

The Git-trailer-compatible footers defined here are
`Reverts`, `Closes`, and the attribution trailers listed below.
Placing `Reverts` and `Closes` above any other footers is recommeneded.

##### Custom footers

Commits MUST NOT use footers that have not been defined.
Projects MAY define additional footers.

1. MUST NOT redefine any footer defined here;
2. MUST follow the Git trailer syntax;
3. MUST use either `: ` or ` #` as a separator;
4. SHOULD have key matching `[A-Z][A-Za-z0-9]*+(?:-[A-Za-z0-9]++)*+`; and
5. SHOULD clearly document
   (i) when it’s allowed and/or required,
   (ii) the value syntax and meaning,
   (iii) whether it’s repeatable, and
   (iv) any aliases for the key.

#### Attribution trailers

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

This regex could be used to parse attribution trailers:

```regexp
(?<key> [A-Z][A-Za-z]*+(?:-[a-z]++)*+)
\u0020
(?<author> [^\s<>](?:[^\s<>]|\u0020)+(?!\u0020) )
\u0020
< (?<email>[\w.+-]++@[\w.-]++\.[a-z]++) >
```

### Differences from other conventions

There are differences between
these guidelines,
the [PyData guidelines](https://sparse.pydata.org/en/latest/contributing/#contributing-code),
and the
[Angular guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md).
Note that PyData defers to a
[2018 Angular revision](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#type).

| thing                  | Angular               | this spec        | rationale                          |
| ---------------------- | --------------------- | ---------------- | ---------------------------------- |
| multiple scopes?       | no                    | comma-separated  | Often multiple apply               |
| dev scope (main)       | `dev-infra`           | ← _(unchanged)_  |                                    |
| dev scope (docs)       | `docs-infra`          | ←                |                                    |
| deprecation footer     | `DEPRECATED:`         | ←                |                                    |
| issue close footer     | GH-recognized †       | only `Closes #`  | Prefer single keyword              |
| PR footer              | yes, like issue       | no               | Handle in issue, not PR/commit     |
| has `revert` type      | yes                   | no               | Treat it as a normal commit        |
| revert hash (body)     | `This commit reverts` | ←                | Prominent keyword                  |
| has `depr` type        | no                    | yes              | Changelog section                  |
| has `drop` type        | no                    | yes              | Changelog section                  |
| has `security` type    | no                    | yes              | Changelog section                  |
| has `style` type       | removed (2017)        | retained         | Clearly different from `refactor`  |
| has `chore` type       | removed (2017)        | discouraged      | Preferred to an incorrect type     |
| body mood              | imperative            | non-imperative   | More readable; de facto in Angular |
| body format            | plain                 | CommonMark       | More flexible; rendered on GitHub  |
| `!` required           | no                    | yes              | Important, so specify in subject   |
| line length            | not specified         | ≤ 100 encouraged | Consistency and readability        |
| special paragraphs ‡   | footers               | body paragraphs  | Conform to Git trailer format      |
| special paragraph text | ≥ 2 paragraphs        | ≥ 1 paragraph    | Keep thing simple                  |

/// table-caption
<b>Differences from the Angular commit guidelines</b>
///

<small>
<b>†</b> _GH-recognized_ means any phrase that GitHub sees as
[PR-to-issue links](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword).\
<b>‡</b> Whether `BREAKING CHANGES` and (if defined) `DEPRECATED`
are footers or special body paragraphs.
</small>
