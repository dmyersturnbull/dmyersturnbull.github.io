# Issue labels

This is a list of issue labels intended to complement the [contributor guide](contributor-guide.md).
They are used in the [CICD repo](https://github.com/dmyersturnbull/cicd).

!!! info "To use in your projects"

    Link to https://dmyersturnbull.github.io/ref/contributor-guide/.
    Refer to that guide for information.
    To add these to GitHub programmatically, refer to [CICD](https://github.com/dmyersturnbull/cicd) or see below.

!!! info "Another way to use"

    Please feel free to use some or all of these in your projects or guidelines.
    No need to credit.

There are 6 groups:

- `type`: The kind of changes (matches commit types)
- `priority`: The importance and urgency
- `state`: What type of work needs to be done (development work is just 1 type)
- `effort`: How much work it requires
- `scope`: The component (matches commit scopes)
- `breaking`: Whether breaking changes are required (for issues) or made (for PRs)
- miscellaneous: `help needed` (to request help),
  `bookmark` (for issues that contain important information),
  `changelog: include` (always list in the changelog under _🍒 Miscellaneous_),
  and `changelog: exclude` (never list in the changelog)

`type` is required for both issues and PRs.
The `type` of a PR should match its commit type when squashed.
`priority`, `effort`, and `scope` should be used when they are helpful.

## Table

| Label                   | Commit part | Changelog section   | Bump  | Icon | Description                     | Color    |
|-------------------------|-------------|---------------------|-------|------|---------------------------------|----------|
| `breaking`              | `!`         | 💥 Breaking changes | major | 💥   | Breaking change                 | `000000` |
| `help needed`           | N/A         | N/A                 | N/A   | 👋   | Help needed                     | `40f040` |
| `bookmark`              | N/A         | N/A                 | N/A   | 🔖   | Important for reference         | `ffff44` |
| `changelog: include`    | N/A         | N/A                 | N/A   | 🔔   | Always include in changelog     | `ffe6e6` |
| `changelog: exclude`    | N/A         | N/A                 | N/A   | 🔕   | Always omit from changelog      | `eeeeee` |
| `type: drop`            | `drop:`     | 💥 Breaking changes | major | ❌    | Drop a feature                  | `440000` |
| `type: security`        | `security:` | 🔒️ Security        | minor | 🔒️  | Fix a security issue            | `000060` |
| `type: deprecation`     | `depr:`     | 🗑️ Deprecations    | minor | 🗑️  | Deprecate something public      | `101030` |
| `type: feature`         | `feat:`     | ✨ Features          | minor | ✨    | Add or change a feature         | `000060` |
| `type: fix`             | `fix:`      | 🐛 Bug fixes        | patch | 🐛   | Fix a bug                       | `000060` |
| `type: docs`            | `docs:`     | 📝 Documentation    | patch | 📝   | Modify docs or examples         | `000060` |
| `type: build`           | `build:`    | 🔧 Build system     | minor | 🔧   | Modify build or dependencies    | `000060` |
| `type: performance`     | `perf:`     | ⚡️ Performance      | patch | ⚡️   | Reduce resource usage           | `000060` |
| `type: test`            | `test:`     | 🍒 Miscellaneous    | none  | 🚨   | Add or modify tests             | `000060` |
| `type: cicd`            | `ci:`       | 🍒 Miscellaneous    | none  | ⚙️   | Modify CI/CD                    | `000060` |
| `type: refactor`        | `refactor:` | 🍒 Miscellaneous    | none  | ♻️   | Refactor source code            | `000060` |
| `type: style`           | `style:`    | skipped             | none  | 🎨   | Modify code style               | `000060` |
| `type: chore`           | `chore:`    | skipped             | none  | 🧹   | Other type of change            | `000060` |
| N/A                     | `release:`  | skipped             | N/A   | ✉️   | Bump the version and deploy     | `000000` |
| `priority: critical`    | N/A         | N/A                 | N/A   | 🟥   | Must be fixed ASAP              | `ff6600` |
| `priority: high`        | N/A         | N/A                 | N/A   | 🟧   | Stalls work; must be fixed soon | `cc9911` |
| `priority: medium`      | N/A         | N/A                 | N/A   | 🟨   | Not blocking but important      | `ff6600` |
| `priority: low`         | N/A         | N/A                 | N/A   | 🟩   | No need to rush                 | `99dd00` |
| `state: ready for dev`  | N/A         | N/A                 | N/A   | 🏁   | Ready for development work      | `cccccc` |
| `state: needs triage`   | N/A         | N/A                 | N/A   | 🚦   | Needs to be triaged             | `444444` |
| `state: blocked`        | N/A         | N/A                 | N/A   | 🚧   | Blocked by another issue        | `999999` |
| `state: needs details`  | N/A         | N/A                 | N/A   | 🏷️  | Requires ticket work            | `666666` |
| `state: rejected`       | N/A         | N/A                 | N/A   | ✖️   | Will not be worked on           | `eeeeee` |
| `effort: 1`             | N/A         | N/A                 | N/A   | 1️⃣  | Easy (t < 1 hr)                 | `300040` |
| `effort: 2`             | N/A         | N/A                 | N/A   | 2️⃣  | Moderate (1 hr <= t < 4 hr)     | `600040` |
| `effort: 3`             | N/A         | N/A                 | N/A   | 3️⃣️ | Hard (>= 4 hours)               | `900040` |
| `effort: multipart`     | N/A         | N/A                 | N/A   | *️⃣  | References multiple issues      | `a00010` |
| `scope: i18n`           | `(i18n)`    | N/A                 | N/A   | 🌐   | Relates to internationalization | `009000` |
| `scope: plugins` (e.g.) | `(plugins)` | N/A                 | N/A   | 🧩   | Relates to plugins              | `000090` |

??? details "Add programmatically"

    These scripts script should add the labels.
    They will not remove existing labels; you will have to do that yourself.
    They may fail if you have existing labels with the same names.

    === "Bash"

        ```bash
        org="my_github_user_or_org"
        repo="my_github_repo"
        labels=$(cat <<-EOF
        {
          "labels": [
            {
              "name": "breaking",
              "description": "💥 Breaking change",
              "color": "#000000"
            },
            {
              "name": "help needed",
              "description": "👋 Help needed",
              "color": "#40f040"
            },
            {
              "name": "bookmark",
              "description": "🔖 Important for reference",
              "color": "#ffff44"
            },
            {
              "name": "changelog: include",
              "description": "🔔 Always include in the changelog",
              "color": "#ffe6e6"
            },
            {
              "name": "changelog: exclude",
              "description": "🔕 Always omit from the changelog",
              "color": "#eeeeee"
            },
            {
              "name": "type: drop",
              "description": "❌ Removal of a feature",
              "color": "#440000"
            },
            {
              "name": "type: feature",
              "description": "✨ Addition or modification of a feature",
              "color": "#000060"
            },
            {
              "name": "type: security",
              "description": "🔒️ Vulnerability fix/mitigation or hardening",
              "color": "#000060"
            },
            {
              "name": "type: deprecation",
              "description": "🗑️ Deprecation of a feature or component",
              "color": "#000000"
            },
            {
              "name": "type: fix",
              "description": "🐛 Bug fix, excluding security vulnerabilities",
              "color": "#000060"
            },
            {
              "name": "type: performance",
              "description": "⚡️ Code change that improves performance",
              "color": "#000060"
            },
            {
              "name": "type: build",
              "description": "🔧 Change to the build system or external dependencies",
              "color": "#000060"
            },
            {
              "name": "type: docs",
              "description": "📝 Change to documentation only",
              "color": "#000060"
            },
            {
              "name": "type: refactor",
              "description": "♻️ Code change that neither fixes a bug nor adds or modifies a feature",
              "color": "#000060"
            },
            {
              "name": "type: test",
              "description": "🚨 Addition or modification of tests",
              "color": "#000060"
            },
            {
              "name": "type: cicd",
              "description": "⚙️ Change to continuous integration and deployment (CI/CD)",
              "color": "#000060"
            },
            {
              "name": "type: style",
              "description": "🎨 Code change that does not affect the meaning of the code",
              "color": "#000060"
            },
            {
              "name": "type: chore",
              "description": "️🧹 Other type of change",
              "color": "#000060"
            },
            {
              "name": "priority: critical",
              "description": "🟥 Must be fixed ASAP",
              "color": "#ff6600"
            },
            {
              "name": "priority: high",
              "description": "🟧 Stalls work on the project or its dependents",
              "color": "#cc9911"
            },
            {
              "name": " priority: medium",
              "description": "🟨 Does not block release/milestone but should be prioritized",
              "color": "#cccc11"
            },
            {
              "name": "priority: low",
              "description": "🟩 Does not block release/milestone and can be done at any time",
              "color": "#99dd00"
            },
            {
              "name": "state: ready for dev",
              "description": "🏁 Ready for work",
              "color": "#cccccc"
            },
            {
              "name": "state: blocked",
              "description": "🚧 Blocked by another issue",
              "color": "#999999"
            },
            {
              "name": "state: needs details",
              "description": "🏷️ Needs more details before work can begin",
              "color": "#666666"
            },
            {
              "name": "state: rejected",
              "description": "✖️ Will not be worked on",
              "color": "#eeeeee"
            },
            {
              "name": "state: awaiting triage",
              "description": "🚦 Awaiting triage",
              "color": "#444444"
            },
            {
              "name": "effort: 1",
              "description": "1️⃣ Easy (t < 1 hr)",
              "color": "#300040"
            },
            {
              "name": "effort: 2",
              "description": "2️⃣ Moderate (1 hr ≤ t < 4 hr)",
              "color": "#600040"
            },
            {
              "name": "effort: 3",
              "description": "3️⃣️ Hard (≥ 4 hours)",
              "color": "#900040"
            },
            {
              "name": "effort: multipart",
              "description": "*️⃣ Organizes multiple sub-issues",
              "color": "#900040"
            },
            {
              "name": "scope: plugin",
              "description": "🧩 Plugins",
              "color": "#009000"
            },
            {
              "name": "scope: i18n",
              "description": "🌐 Internationalization",
              "color": "#009000"
            }
          ]
        }
            EOF
        )

        jq -c '.[]' <<< "${labels}" | while read label; do
          curl -L \
            -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${token}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/repos/${org}/${repo}/labels \
            -d '${label}'
        done
        ```

    === "PowerShell"

      TODO

!!! info "Motivation"

    - Compatible with the [Angular commit types](https://github.com/angular/angular/blob/main/CONTRIBUTING.md)
      and map naturally to changelog headings
    - Easy to type and obviously named
    - Reuse types that are common in the wild, such as _effort_ and _priority_
    - Try to avoid names and emojis that conflict with well-known types (e.g., gitmoji).
    - Not include chat/question types (which Conversations should be used for)
      or states that occur post-triage, which Projects and issue actions should be used for (e.g., "state: completed")

    **References:**

    - [Creative Commons](https://opensource.creativecommons.org/contributing-code/repo-labels/)
    - [Gitmoji](https://gitmoji.dev/)
    - [Sean Trane’s labels](https://seantrane.com/posts/logical-colorful-github-labels-18230/)
    - [Conventional changelog metahub](https://github.com/pvdlg/conventional-changelog-metahub)
