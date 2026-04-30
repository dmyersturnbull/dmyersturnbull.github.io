---
tags:
  - GitHub
  - DevOps
---

# GitHub Actions

<!--
SPDX-FileCopyrightText: Copyright 2017-2026, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Coercion to boolean

| type   | coerced value | mnemonic                       | **true** values | **false** values |
| ------ | ------------- | ------------------------------ | --------------- | ---------------- |
| string | `!= ''`       | true if **nonempty**           | `'false'`       | `''` (only)      |
| number | `!= 0`        | true if **nonzero**            | `-1`, `2.5`     | `0` (only)       |
| null   | `false`       | **always false**               | ∅               | 𝕌                |
| object | `true`        | **always true**, even if empty | 𝕌               | ∅                |
| array  | `true`        | **always true**, even if empty | 𝕌               | ∅                |

## Allowed contexts

| workflow key                           | `github` | `needs` | `strategy` | `matrix` | `job` | `runner` | `env` | `vars` | `secrets` | `steps` | `inputs` | `jobs` | FNs |
| -------------------------------------- | -------- | ------- | ---------- | -------- | ----- | -------- | ----- | ------ | --------- | ------- | -------- | ------ | --- |
| `run-name`                             | +        |         |            |          |       |          |       | +      |           |         | +        |        |     |
| `concurrency`                          | +        |         |            |          |       |          |       | +      |           |         | +        |        |     |
| `env`                                  | +        |         |            |          |       |          |       | +      | +         |         | +        |        |     |
| `jobs.<job_id>.concurrency`            | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| `jobs.<job_id>.` **…**                 | ·        | ·       | ·          | ·        | ·     | ·        | ·     | ·      | ·         | ·       | ·        | ·      | ·   |
| … `container`                          | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `container.credentials`              | +        | +       | +          | +        |       |          | +     | +      | +         |         | +        |        |     |
| … `container.env.<env_id>`             | +        | +       | +          | +        | +     | +        | +     | +      | +         |         | +        |        |     |
| … `container.image`                    | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `continue-on-error`                  | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `defaults.run`                       | +        | +       | +          | +        |       |          | +     | +      |           |         | +        |        |     |
| … `env`                                | +        | +       | +          | +        |       |          |       | +      | +         |         | +        |        |     |
| … `environment`                        | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `environment.url`                    | +        | +       | +          | +        | +     | +        | +     | +      |           | +       | +        |        |     |
| … `if`                                 | +        | +       |            |          |       |          |       | +      |           |         | +        |        | †   |
| … `name`                               | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `outputs.<output_id>`                | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        |     |
| … `runs-on`                            | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `secrets.<secrets_id>`               | +        | +       | +          | +        |       |          |       | +      | +         |         | +        |        |     |
| … `services`                           | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `services.<service_id>.credentials`  | +        | +       | +          | +        |       |          | +     | +      | +         |         | +        |        |     |
| … `services.<service_id>.env.<env_id>` | +        | +       | +          | +        | +     | +        | +     | +      | +         |         | +        |        |     |
| … `steps.continue-on-error`            | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        | ‡   |
| … `steps.env`                          | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        | ‡   |
| … `steps.if`                           | +        | +       | +          | +        | +     | +        | +     | +      |           | +       | +        |        | †,‡ |
| … `steps.name`                         | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        | ‡   |
| … `steps.run`                          | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        | ‡   |
| … `steps.timeout-minutes`              | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        | ‡   |
| … `steps.with`                         | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        | ‡   |
| … `steps.working-directory`            | +        | +       | +          | +        | +     | +        | +     | +      | +         | +       | +        |        | ‡   |
| … `strategy`                           | +        | +       |            |          |       |          |       | +      |           |         | +        |        |     |
| … `timeout-minutes`                    | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| … `with.<with_id>`                     | +        | +       | +          | +        |       |          |       | +      |           |         | +        |        |     |
| `on.workflow_call.` **…**              | +        |         |            |          |       |          |       | +      |           |         | +        |        |     |
| … `inputs.<inputs_id>.default`         | +        |         |            |          |       |          |       | +      |           |         | +        |        |     |
| … `outputs.<output_id>.value`          | +        |         |            |          |       |          |       | +      |           |         | +        | +      |     |

<small>
<b>†</b> `always`, `cancelled`, `success`, `failure`\
<b>‡</b> `hashFiles`
</small>
