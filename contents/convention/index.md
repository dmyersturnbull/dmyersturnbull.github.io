# Conventions

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

---

<strong class="index">Contents</strong>

[:fontawesome-solid-cloud: **APIs**](apis.md):
REST APIs and data representation

[:fontawesome-solid-book-open: **Documentation**](documentation.md):
Writing and maintaining documentation

[:fontawesome-solid-mug-hot: **Java**](java.md):
Java and Kotlin conventions

[:fontawesome-solid-code: **JavaScript and TypeScript**](javascript-and-typescript.md):
JavaScript and TypeScript conventions

[:fontawesome-solid-dragon: **Python**](python.md):
Python conventions

[:fontawesome-solid-terminal: **Scripts and build files**](scripts-and-build-files.md):
Conventions for shell scripts, build files, etc.

[:fontawesome-solid-database: **SQL**](sql.md):
SQL conventions

---

## Usage

These docs are meant to be linked to.
Include a link in your project’s readme or `CONTRIBUTING.md` file.

???+ example

    ```markdown
    See https://dmyersturnbull.github.io/style/java/
    but disregard the `security:` commit type, which we don’t use.
    ```

    Or just link to individual sections; e.g.

    ```markdown
    ### File names: See https://dmyersturnbull.github.io/ref/style/documentation#filenames
    ```

    These guidelines may be too detailed for most contributors.
    Rather than pointing contributors here,
    it may be better for maintainers to enforce these rules by editing contributors’ pull requests.

## Auto-formatters

Whenever possible, let tools auto-format your code.

Use the auto-formatter setup in the
[tyranno-sandbox repo](https://github.com/dmyersturnbull/tyranno-sandbox).
This includes `.editorconfig`,
[Prettier](https://prettier.io/), and
the [Ruff formatter](https://docs.astral.sh/ruff/formatter/)
(which is equivalent to [Black](https://github.com/psf/black)).

Prettier handles all the formatting for JavaScript, TypeScript, HTML, and CSS,
and some of the formatting for Markdown and some other languages.
For Java and Kotlin, the
[IntelliJ formatter settings](intellij-style.xml)
can handle some of the formatting conventions for those languages.

These auto-formatters are meant to be run via
[pre-commit](https://pre-commit.com/)
or before each merge.
This document lists non-formatting guidelines (e.g. accessibility)
and formatting conventions that auto-formatters do not handle.

## Line lengths

Try to limit lines to ≤ 100 characters, but it’s ok if some lines are longer.
**If breaking a line would make the code less readable, leave it alone.**
Note that both Prettier and the Ruff formatter take this approach and will accept some longer lines.

## Principles

Auto-formatters generally remove unnecessary syntax elements.
Default options for linters tend to do the same.
For example, unnecessary parentheses are stripped out.
In these guidelines, I mimic that wherever possible (and reasonable).
