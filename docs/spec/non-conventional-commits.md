---
tags:
  - Git
  - GitHub
  - regex-BNF
---

# Non-conventional commits

<!--
SPDX-FileCopyrightText: Copyright 2017-2026, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

<b>Spec status: unstable.</b>

There are significant well-recognized problems with Conventional Commits.
This nascent specification simply explores alternatives.

!!! abstract "Also see"

    - [Restricted conventional commits spec](commit-messages.md).

<b>Syntax:</b>

Written in [regex-bnf](regex-bnf.md); `*?` is lazy 0-or-more, and `!` is complement.

```ebnf
message        = subject (body footer?)?
subject        = scopes? change extra?
scopes         = '[' scope (',' scope)* '] '
scope          = SCOPE-KEY SCOPE-SIG?
SCOPE-KEY      = [a-z0-9]+(?:-[a-z0-9]+)*          ; e.g. `web-api`
SCOPE-SIG      = [^a-z0-9\n\t]+                    ; e.g. `!`
change         = STD-VERB TYPE ENTITY              ; e.g. `fix class Abc`
               | MOVE-VERB TYPE ENTITY 'to' ENTITY ; e.g. `move class Abc to Xyz`
               | 'update' REALM                    ; e.g. `update dev-deps`
               | 'release' TAG                     ; e.g. `release v0.1.2`
STD-VERB       = [a-z]+                            ; listed in table below
MOVE-VERB      = 'move' | 'rename'
ENTITY         = [^\n]+
REALM          = [a-z-]+                           ; e.g. 'dev-deps'
TAG            = [a-z0-9.+=,_-]+
extra          = ' ' TEXT
TEXT           = [^\n\t]+

body           = ('\n\n' PARAGRAPH)+
PARAGRAPH      = `[^\n](?!.*\n\n).*?(?<!\n)`       ; no '.*\n\n.*', `\n.*`, or `.*\n`

footer         = '\n' ('\n' trailer)*
trailer        = T-KEY (':' | ' #') T-VALUE

T-KEY          = [A-Z][A-Za-z]*+(?:-[a-z]+)*+      ; e.g. `Signed-off-by`
T-VALUE        = [^\s]+
```

## _scope_

`scopes` states how users may be affected or care about the changes,
including whether the changes are breaking for those users.
Reach values MUST be restricted to an enum defined by the project.
Conceptually, each scope is the intersection of
(1) a usage type (`SCOPE-KEY`) and
(2) how the changes affect that usage (`SCOPE-SIG`).

Projects SHOULD use `!` as the scope significance to denote breaking changes.
Projects MAY define other scope signifiance values.
Projects MAY restrict some significance values to some keys
and MAY restrict the combinations of scope values allowed together.
Projects SHOULD assume that any change without a scope list is only relevant to internal developers.

For example, a JavaScript-based HTTP service might define these:

```ebnf
scope  = 'http'   ; OpenAPI service
       | 'http!'  ; Breaking changes increment the OpenAPI version.
       | 'js'     ; JavaScript API published to NPM
       | 'js!'    ; Breaking changes increment major version of NPM package.
       | 'helm!'  ; Any change to the Helm charts (always assumed breaking)
```

This allows the HTTP API, NPM package, and Helm charts to be versioned separately and automatically.
Separate release note sets can also be generated.

## _summary_

<b>`summary`</b>` is defined by this table:

| Phrase    | Syntax (prefix)                | Description                    | Bump? | Section?        |
|-----------|--------------------------------|--------------------------------|-------|-----------------|
| modify    | `modify {api-type} {x}`        | modify a class, endpoint, etc. | major | `Changes`       |
| rename ♮  | `rename {api-type} {a} to {b}` | rename a class, endpoint, etc. | major | `Changes`       |
| move ♮    | `move {api-type} {a} to {b}`   | move a class, endpoint, etc.   | major | `Changes`       |
| remove    | `remove {api-type} {x}`        | remove a class, endpoint, etc. | major | `Removals`      |
| support   | `support {support-type} {x}`   | support an OS, browser, etc.   | minor | `Install`       |
| drop      | `drop {support-type} {x}`      | drop an OS, browser, etc.      | major | `Install`       |
| alter     | `alter {process-type} {x}`     | alter a build process          | major | `Install`       |
| introduce | `introduce {api-type} {x}`     | introduce a new feature        | minor | `New features`  |
| add       | `add {api-type} {x}`           | add a new feature _(alias)_    | minor | `New features`  |
| deprecate | `deprecate {api-type} {x}`     | deprecate a feature            | minor | `Deprecations`  |
| fix       | `fix {api-type} {x}`           | fix a non-security bug         | patch | `Bug fixes`     |
| patch     | `patch {api-type} {x}`         | patch a vulnerability          | patch | `Security`      |
| optimize  | `optimize {api-type} {x}`      | optimize performance           | patch | `Performance`   |
| document  | `document {api-type} {x}`      | document something             | -     | `Documentation` |
| revise    | `revise {doc-type} {x}`        | existing documentation         | -     | `Documentation` |
| correct   | `correct {doc-type} {x}`       | mistake(s) in docs             | -     | `Documentation` |
| test      | `test {api-type} {x}`          | test something                 | -     | `Internal`      |
| repair    | `repair {test-type} {x}`       | repair broken test(s)          | -     | `Internal`      |
| refactor  | `refactor {api-type} {x}`      | refactor code                  | -     | `Internal`      |
| organize  | `organize {path-type} {x}`     | organize repo files            | -     | `Internal`      |
| format    | `format {path-type} {x}`       | format file(s)                 | -     | `Internal`      |
| update ♮  | `update {realm}`               | update lockfile                | patch | `Internal`      |
| release ♮ | `release {tag}`                | release a new version          | -     | -               |

/// table-caption
<b>Change phrases.</b>
♮ ― different/unique structure
///

### Terminology

- `api-type`: `feature | endpoint | command | class | method | function | ...`
- `support-type`: `platform | browser | {tool} version | ...`
- `process-type`: `install | build | ...`
- `doc-type`: `document | guide | ...`
- `test-type`: `test | unit test | ...`
- `path-type`: `file | files`
- `x`: entity (name, endpoint, path, package, system, platform, etc.)
- `a`, `b`: source and destination, respectively
- `realm`: `runtime-deps | dev-deps | ...`
- `tag`: semver Git tag

## Trailers

| Syntax                        | Meaning                         |
|-------------------------------|---------------------------------|
| `Closes #{ticket}`            | Issue to close (repeatable)     |
| `Reverts: {hash-12-digits}`   | Commit being reverted           |
| `Signed-off-by` (and similar) | Attribution (repeatable)        |
| Repo-defined                  | Any purpose                     |

## Examples

<b>Commit history:</b>

```text
[http!] remove endpoints deprecated in v2
[http!] drop platform macOS Yosemite
[http] patch XSS vulnerability in docs playground tool
[http] correct API guide (fix typo)
[http] support language Japanese
[http] add endpoints /undo and /redo
fix script prep-release.py
update dev-deps
remove script for docker deploy (was unused)
refactor class ErrorRoutes
test class DeltaCalc
```

<b>Release notes:</b>

```markdown
## v1.2.0 – 2025-05-07T14:12:35Z

### New features

- Support language Japanese (PR #15)
- Add endpoints /undo and /redo (PR #16)

### Security

- Patch XSS vulnerability in docs playground tool (PR #13)

### Removals

- Remove endpoints deprecated in v2 (PR #11)
- Drop platform macOS Yosemite (PR #12)

### Miscellaneous

- Correct API guide (fix typo) (PR #14)

### Internal

- Fix internal utility scripts (PR #17)
- Update dev-deps (PR #18)
- Remove script for docker deploy (was unused) (PR #19)
- Refactor class ErrorRoutes (PR #20)
- Test class DeltaCalc (PR #21)
```
