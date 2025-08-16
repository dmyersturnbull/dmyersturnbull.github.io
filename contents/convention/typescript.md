---
tags:
  - JavaScript
  - TypeScript
---

# TypeScript conventions

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

Also covers JavaScript.

## Practices

Where applicable, follow the [Java guidelines](java.md).

Always use strict mode, and generally use `===`, not `==`.
Use [`for`…`of`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of)
instead of `for`…`in`.

## Formatting

[Prettier](https://prettier.io/) will handle almost all formatting.
Just set the max line length to 100.
