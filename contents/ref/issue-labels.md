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
- miscellaneous: `help` (to request help) and `bookmark` (for issues that contain important information)

`type` is required for both issues and PRs.
The `type` of a PR should match its commit type when squashed.
`priority`, `state`, `effort`, and `scope` should be used when they are helpful.

## Table

--8<-- "_label-table.md"

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
                  "name": "help",
                  "description": "👋 Help needed",
                  "color": "#40f040"
                },
                {
                  "name": "bookmark",
                  "description": "🔖 Important for reference",
                  "color": "#ffff44"
                },
                {
                  "name": "type: deprecation",
                  "description": "🗑️ Deprecate something public",
                  "color": "#101030"
                },
                {
                  "name": "type: fix",
                  "description": "🐛 Fix a bug",
                  "color": "#000060"
                },
                {
                  "name": "type: security",
                  "description": "🔒️ Fix a security issue",
                  "color": "#000060"
                },
                {
                  "name": "type: feature",
                  "description": "✨ Add or change a feature",
                  "color": "#000060"
                },
                {
                  "name": "type: performance",
                  "description": "⚡️ Reduce resource usage",
                  "color": "#000060"
                },
                {
                  "name": "type: docs",
                  "description": "📝 Modify docs or examples ",
                  "color": "#000060"
                },
                {
                  "name": "type: build",
                  "description": "🔧 Modify build or dependencies",
                  "color": "#000060"
                },
                {
                  "name": "type: refactor",
                  "description": "♻️ Refactor source code",
                  "color": "#000060"
                },
                {
                  "name": "type: test",
                  "description": "🚨 Add or modify tests",
                  "color": "#000060"
                },
                {
                  "name": "type: cicd",
                  "description": "⚙️ Modify CI/CD",
                  "color": "#000060"
                },
                {
                  "name": "type: style",
                  "description": "🎨 Modify code style",
                  "color": "#000060"
                },
                {
                  "name": "type: chore",
                  "description": "️🧹 Misc. change not to source",
                  "color": "#000060"
                },
                {
                  "name": "priority: critical",
                  "description": "🟥 Must be fixed ASAP",
                  "color": "#ff6600"
                },
                {
                  "name": "priority: high",
                  "description": "🟧 Stalls work; must be fixed soon",
                  "color": "#cc9911"
                },
                {
                  "name": "priority: medium",
                  "description": "🟨 Not blocking but important",
                  "color": "#cccc11"
                },
                {
                  "name": "priority: low",
                  "description": "🟩 No need to rush",
                  "color": "#99dd00"
                },
                {
                  "name": "state: ready for dev",
                  "description": "🏁 Ready for development work",
                  "color": "#cccccc"
                },
                {
                  "name": "state: blocked",
                  "description": "🚧 Blocked by another issue",
                  "color": "#999999"
                },
                {
                  "name": "state: needs details",
                  "description": "🏷️ Requires ticket work",
                  "color": "#666666"
                },
                {
                  "name": "state: discarded",
                  "description": "🗑️ Will not be worked on",
                  "color": "#eeeeee"
                },
                {
                  "name": "state: invalid",
                  "description": "➖ Duplicate, inadvertant, etc.",
                  "color": "#eeeeee"
                },
                {
                  "name": "state: needs triage",
                  "description": "🚦 Needs to be triaged",
                  "color": "#444444"
                },
                {
                  "name": "effort: 1",
                  "description": "1️⃣ Easy (t < 1 hr)",
                  "color": "#300040"
                },
                {
                  "name": "effort: 2",
                  "description": "2️⃣ Moderate (1 hr <= t < 4 hr)",
                  "color": "#600040"
                },
                {
                  "name": "effort: 3",
                  "description": "3️⃣ Hard (>= 4 hours)",
                  "color": "#900040"
                },
                {
                  "name": "effort: multipart",
                  "description": "*️⃣ References multiple issues",
                  "color": "#900040"
                },
                {
                  "name": "scope: docker",
                  "description": "🐬 Docker",
                  "color": "#009000"
                },
                {
                  "name": "scope: plugins",
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
