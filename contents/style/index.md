# Coding guidelines & conventions

## Usage

These docs are meant to be linked to.
Include a link in your project’s readme or `CONTRIBUTING.md` file.

!!! example

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

Use the auto-formatter setup in [dmyersturnbull/cicd](https://github.com/dmyersturnbull/cicd).
This includes `.editorconfig`, [Prettier](https://prettier.io/), and
the [Ruff formatter](https://docs.astral.sh/ruff/formatter/)
(which is equivalent to [Black](https://github.com/psf/black)).

Prettier handles all the formatting for JavaScript, TypeScript, HTML, and CSS,
and some of the formatting for Markdown and some other languages.
For Java, Scala, Groovy, and Kotlin, the [IntelliJ formatter settings](intellij-style.xml)
can handle most of the formatting conventions for those languages.

These auto-formatters are meant to be run via [pre-commit](https://pre-commit.com/) or before each merge.
This document lists non-formatting guidelines (e.g. accessibility)
and formatting conventions that auto-formatters do not handle.

## History
