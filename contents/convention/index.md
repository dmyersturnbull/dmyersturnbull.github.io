# Conventions

Recommendations for code, documentation, etc.

## Contents

[:fontawesome-solid-cloud: **APIs**](../convention/apis.md): REST APIs and data representation

[:fontawesome-solid-book-open: **Documentation**](../convention/documentation.md): Writing and maintaining documentation

[:fontawesome-solid-mug-hot: **Java**](../convention/java.md): Java and Kotlin conventions

[:fontawesome-solid-code: **JavaScript**](../convention/javascript.md): JavaScript and TypeScript conventions

[:fontawesome-solid-dragon: **Python**](../convention/python.md): Python conventions

[:fontawesome-solid-terminal: **Scripts and build files**](../convention/scripts-and-build-files.md): Shell scripts, build files, etc.

[:fontawesome-solid-database: **SQL**](../convention/sql.md): SQL conventions

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
For Java and Kotlin, the [IntelliJ formatter settings](intellij-style.xml)
can handle some of the formatting conventions for those languages.

These auto-formatters are meant to be run via [pre-commit](https://pre-commit.com/) or before each merge.
This document lists non-formatting guidelines (e.g. accessibility)
and formatting conventions that auto-formatters do not handle.

## History
