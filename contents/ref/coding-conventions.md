# Coding conventions

!!! abstract "How to use these docs"
    These docs are meant to be linked to.
    Include a link in your project’s readme or `CONTRIBUTING.md` file.
    E.g.,
    ```markdown
    See https://dmyersturnbull.github.io/ref/coding-conventions/
    but disregard the `security:` commit type, which we don’t use.
    ```

    Or just link to individual sections; e.g.,
    ```markdown
    ### File names: See https://dmyersturnbull.github.io/ref/coding-conventions/#filenames
    ```

    These guidelines may be too detailed for most contributors.
    Rather than pointing contributors here,
    it may be better for maintainers to enforce these rules by editing contributors’ pull requests.

Use the auto-formatter setup in [dmyersturnbull/cicd](https://github.com/dmyersturnbull/cicd).
This includes `.editorconfig`, [Prettier](https://prettier.io/), and
the [Ruff formatter](https://docs.astral.sh/ruff/formatter/)
(which is equivalent to [Black](https://github.com/psf/black)).

Prettier handles all the formatting for JavaScript, TypeScript, HTML, and CSS,
and some of the formatting for Markdown and some other languages.
For Java, Scala, Groovy, and Kotlin, the [IntelliJ formatter settings](intellij-style.xml)
can handle most of the formatting conventions for those languages.

These auto-formatters are meant to be run via [pre-commit](https://pre-commit.com/) or before each merge.
**This document lists non-formatting guidelines (e.g., accessibility)**
**and formatting conventions that auto-formatters do not handle.**

## Filenames

!!! tip

    This section can apply to naming of URI nodes, database IDs, and similar constructs.
    These are general guidelines: Alternatives should be used in some situations.
    For example, if camelCase is used in your JSON Schema, use camelCase for schema document filenames.

??? rationale

    The [official YAML extension is `.yaml`](https://yaml.org/faq.html).
    Moreover, the IANA media types are `application/yaml`, `text/html`, and `image/jpeg`.
    `.yml`, `.htm`, and `.jpg` are relics of DOS.
    Extensions are required because provide useful information; ommitting them can cause confusion.
    For example, a file named `info` could be a plain-text info document or a shell script that writes the info.
    Instead, write it as `info.txt` or `info.sh`.

Prefer using kebab-case (e.g., `full-document.pdf`), treating `-` as a space.
Restrict to `-`, `.`, `[a-z]`, and `[0-9]`, unless there is a compelling reason otherwise.
If necessary, `--`, `+`, and `~` can be used as word separators with reserved meanings.
For example, `+` could denote join authorship in `mary-johnson+kerri-swanson-document.pdf`.

Always use one or more filename extensions.
(Name your license file `LICENSE.txt` or `LICENSE.md`.)
Where possible, use `.yaml` for YAML, `.html` for HTML, and `.jpeg` for JPEG.
In particular, **do not** use `.yml`, `.htm`, `.jpg`, or `.jfif`.

## Comments

Comments must be maintained like all other elements of code.
Avoid unnecessary comments, such as those added out of habit or ritual.
Forgo comments that are obvious or otherwise unhelpful.
For example:

=== "❌ Incorrect"

    ```python
    from typing import Self, TypeVar


    class SpecialCache:
        """
        Soft cache supporting the Foobar backend.
        Uses a Least Recently Used (LRU) policy with an expiration duration.
        """

        def get_cache_item(self: Self, key: str) -> T:
            # (1)!
            """
            Gets the cache item corresponding to key `key`.

            Arguments:
                key: A string-valued key

            Returns:
                The value for the key `key`
            """
            return self._items[key]
    ```

    1. This docstring serves no function.

=== "✅ Correct"

    ```python
    from typing import Self, TypeVar


    class SpecialCache:
        """
        Soft cache supporting the Foobar backend.
        Uses a Least Recently Used (LRU) policy with an optional expiration duration.
        """

        def get_cache_item(self: Self, key: str) -> T:
            return self._items[key]
    ```

## Language and grammar

!!! tip

    Apply these guidelines to both comments and documentation.

See [Google’s documentation style guide](https://developers.google.com/style/) for additional guidelines.

### Style

Remove text that is repetitive or superfluous.
Be direct. Use examples, diagrams, formal grammars, pseudocode, and mathematical expressions.
(Write English descriptions for diagrams and any other elements that are be inaccessible to screen readers.)

Keep language accessible:
Introduce or explain jargon, favor simpler words, and replace idioms with literal phrasing.
Use singular _they_ and other gender-neutral terms, and use inclusive language.
Substitute long phrases with shorter ones.

| ❌ Avoid                        | ✅ Preferred    |
|--------------------------------|----------------|
| _utilize_                      | _use_          |
| _due to the fact that_         | _because_      |
| _a great number of_            | _many_         |
| _is able to_                   | _can_          |
| _needless to say_              | (omit)         |
| _it is important to note that_ | _importantly,_ |

Great documentation should not win poetry awards.
Keep things simple and direct.

### Spelling

??? rationale

    American English is the [most widespread dialect](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5969760/),
    and it generally has more phonetic and shorter spellings.

Use American English spelling.

### Grammar and punctuation

Use 1 space between sentences.

Use sentence case for titles and table headers (e.g., _This is a title_).
Capitalize the first word after a colon or semicolon only if it begins a valid sentence.

## Markdown

!!! tip

    Where applicable, apply these guidelines to other documentation, not just Markdown.

### Line breaks

??? rationale

    Keeping each sentence on its own line dramatically improves diffs.

**Break lines at the end of sentences.**
If a line goes over 120 characters, break it after an appropriate punctuation mark.
For example, break up independent clauses, and start a new line before a long hyperlink.
_Note:_ A series of very short sentences can be left on one line.

### Emphasis and semantic markup

#### Italics

**Use `_`/`_` italics for foreign words, technical terms,**
and references to a word or phrase itself (rather than its meaning).**
**Never use italics for emphasis.**
Take `_`/`_` as semantically equivalent to the
[`<i>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i).
Do not italicize ubiquitous foreign phrases such as
_in vivo_, _in sitro_, _in silico_, and _et al._
You can use backticks in places where italics would be unclear; for example, to show Unicode characters.

??? bug

    Unfortunately, grammar checkers do not understand this convention
    and will mark a duplicate _and_ in `Say _and_ and _or_`.

#### Bold

**Use `**`/`**` bold for emphasis.**
Take it as semantically equivalent to the
[`<strong>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/strong).

Use the [`<b>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/b) explicitly
for text that should be bold but is not emphasized – i.e., is offset from the surrounding text.
For example, you might write `<b>Score:</b> 55.3%`.
(`**`/`**` would be inappropriate here.)

#### Code and math

!!! tip

    With the Material for mkdocs
    ["Smarty" plugin](https://squidfunk.github.io/mkdocs-material/reference/formatting/#adding-keyboard-keys),
    you can use `++`/`++` instead of `<kdb>`/`<kdb>`; e.g., `++ctrl+alt+del++`.

Use backticks for code, `<kbd>`/`</kdb>` for keyboard keys,
and LaTeX (`$`/`$`) for variables and mathematical expressions.
To describe menu navigation, use [`➤`](https://www.compart.com/en/unicode/U+27A4) without markup, as in
File ➤ Export ➤ Export as Text.

### Encoding

Write most non-ASCII characters as-is, not with entity references.
For example, write an en dash as `–`, not `&#x2013;`.

However, you may use hexadecimal entity references for

- non-space whitespace characters; and
  (such as [no break space](https://www.compart.com/en/unicode/U+00A0), `&nbsp;`); and
- punctuation that is highly likely to confuse anyone reading the source code
  (such as [soft hyphen](https://www.compart.com/en/unicode/U+00ad), `&#x00ad;`); and
- characters that must be escaped for technical reasons

### Punctuation symbols

!!! tip

    With the Material for mkdocs
    ["Smarty" plugin](https://python-markdown.github.io/extensions/smarty/),
    you can use use `'` and `"` for quotation marks,
    `--` for en dashes, `---` for em dashes, and `...` for ellipses.

Use the correct Unicode characters for punctuation.
That includes:

- `’` for apostrophes
- `‘`, `’`, `“`, and `”` for quotation marks
- `–` (_en dash_) for numerical ranges (e.g., `5–10`)
- `—` (_em dash_) to separate a blockquote and its source
- `‒` (_figure dash_) in numerical formatting
- `…` (_ellipses_)
- `−` (_minus sign_)
- `µ` (_micro sign_)

<small>However, use regular _hyphen-minus_ (U+002D) for hyphens, **not** _hyphen_ (U+2010).</small>

Use an en dash surrounded by spaces (` – `) to mark breaks in thoughts, **not** an em dash.
For example:

```markdown
An en dash – in contrast to an em dash – should be used here.
```

### Quotations

??? rationale

    This preserves the semantic difference between punctuation _inside_ versus _outside_ of quotations.
    This rule is always followed when using code in backticks, anyway.

Place punctuation outside of quotation marks (British-style rules).
For example:

```markdown
Also write “hard”, “difficult”, or “strenuous”.
```

Introduce code blocks with punctuation only where semantically valid.
If it is semantically valid, use a colon rather than a comma.
In blockquotes, use `_— author_` (with an em dash) to cite the source.

??? rationale

    This rule preserves the semantics as much as possible.
    A colon is a visual signal that the prose goes with its following code block, reducing refactoring mistakes.

??? example "Examples"

    In the following block, use _then run_, not _then run:_.

    ````markdown
    Then run

    ```
    ps -a -x
    ```
    ````

    Here, a colon is appropriate:

    ```markdown
    Mark Twain also said:

    > When in doubt‚ tell the truth.
    > This is a blockquote, which is ordinarily introduced by punctuation.
    > For clarity, we introduce such blockquotes with colons.
    > _— Mark Twain_
    ```

### Quantities

!!! rationale

    This is the format that
    [IEEE recommends](https://www.ieee.org/content/dam/ieee-org/ieee/web/org/conferences/style_references_manual.pdf).

To format numbers and dimensioned quantities, use:

- A period (`.`) as the decimal marker
- A narrow no break space, ` ` (NNBSP / U+002D / `&#x202f;`) as the thousands separator
- A full space (` `) to separate magnitude and units

For example: _1 024.222 222 µm_.

Preferably, write units using decimal dot (`·`, [U22C5](https://www.compart.com/en/unicode/U+u22c5)).
For example: _5.4 kg·m²·s⁻²_.
Use `hour` or `hr`, `minute` or `min`, and `second`, `sec`, or `s` as abbreviations.

You can use inline LaTeX (`$`/`$`) to format dimensioned values instead.
E.g., `5.4 kg m^2 s^{-2}`.

### Uncertainty measurements

State whether the values refer to standard error or standard deviation.
_SE_ is an acceptable abbreviation for standard error;
_SD_ is an acceptable abbreviation for standard deviation.

Examples:

- > 7.65 (4.0–12.5, 95% confidence interval)
- > 7.65 ±1.2 (SE)

**❌ Do not** just write the uncertainty without explanation, e.g., `5.0 ±0.1` – it is ambiguous.

**✅ Do** describe how the uncertainty was estimated (i.e., a statistical test).

### Dates and times

Use [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339).
For example: `2023-11-02T14:55:00 -08:00`.
Note that the UTC offset is written with a hyphen, not a minus sign.
If a timezone is needed, use a recognized IANA timezone such as `America/Los_Angeles`,
and set it in square brackets.
The UTC offset must still be included.
For example: `2023-11-02T14:55:00 -08:00 [America/Los_Angeles]`.

### Paths and filesystem trees

Always use `/` as a path separator in documentation, and denote directories with a trailing `/`.

For filesystem trees, use Unicode box-drawing characters.
Refer to the
[research projects guide](https://dmyersturnbull.github.io/guide/research-projects/#example)
for an example.

### Accessibility

Use descriptive titles for link titles.
For example, write:

```markdown
Refer to the [coding conventions](coding-conventions.md).
```

**Not:**

```markdown
Click [here](coding-conventions.md) for conding conventions.
```

## HTML

Follow the general guidelines in the Markdown section.

### Attribute values

Use kebab-case for `id` and `name` values and for `data` keys and values.

Skip the `type` attribute  for scripts and stylesheets.
Instead, use `<link rel="stylesheet" href="..." />` for stylesheets
and `<script src="..." />` for scripts.

### Accessibility

Use the `alt` attribute for media elements, including `<img>`, `<video>`, `<audio>`, and `<canvas>`.

### Formatting

Use [Prettier](https://prettier.io/) with default options except for line length, which must be 120.

!!! note

    Prettier wraps tags in way that looks strange at first.
    It does that to avoid adding extra whitespace.

#### Closing tags

??? rationale

    Requiring closing tags (and trailing slashes, which Prettier will add)
    improves readability and simplifies parsing.

Always close tags.
For example, use `<p>The end.</p>`, **not** `<p>The end.`.

#### `<html>`, `<head>`, and `<body>` elements

??? rationale

    The rules for
    [ommitting `<html>`, `<head>`, and `<body>`](https://html.spec.whatwg.org/#syntax-tag-omission)
    are complex and better ignored.

Always include these elements.

## HTTP APIs

### Status codes

This section applies to REST-like HTTP APIs.
Servers should only issue response codes in accordance with the following table.

Note that 404 (Not Found) is reserved for resources that _could_ exist but do not;
Attempts to access an invalid endpoint must always generate a 400 (Bad Request).

<small>
<b>Note:</b> Some or even most of these might not apply!
For example, your server might not implement HTTP content negotiation.
</small>

| code | name                       | methods                       | Body     | use case                            |
|------|----------------------------|-------------------------------|----------|-------------------------------------|
| 100  | Continue                   | `POST`/`PUT`/`PATCH`          | ∅        | `Expect: 100-continue` ok           |
| 200  | OK                         | `GET`/`HEAD`/`PATCH`          | resource |                                     |
| 201  | Created                    | `POST`/`PUT`                  | resource |                                     |
| 202  | Accepted                   | `POST`                        | ∅        |                                     |
| 204  | No Content                 | `DELETE`                      | ∅        | Successful deletion                 |
| 206  | Partial Content            | `GET`                         | partial  | Range was requested                 |
| 303  | See Other †                | any                           | ∅        | Removed endpoint has alternative    |
| 304  | Not Modified               | `GET`/`HEAD`                  | ∅        | `If-None-Match` matches             |
| 308  | Permanent Redirect †       | any                           | ∅        | Endpoint moved                      |
| 400  | Bad Request                | any                           | ∅        | Invalid endpoint                    |
| 401  | Unauthorized               | any                           | ∅        | Not authenticated                   |
| 403  | Forbidden                  | any                           | ∅        | Insufficient privileges             |
| 404  | Not Found                  | `GET`/`DELETE`/`PATCH`        | ∅        | Resource does not exist             |
| 406  | Not Acceptable             | `GET`/`HEAD`                  | error    | `Accept` headers unsatisfiable      |
| 409  | Conflict                   | `PUT`/`POST`                  | error    | Resource already exists             |
| 410  | Gone †                     | any                           | error/∅  | Endpoint removed                    |
| 412  | Precondition Failed        | `POST`/`PUT`/`DELETE`/`PATCH` | error/∅  | Mid-air edit (`If-...`)             |
| 413  | Content Too Large †        | `POST`/`PUT`/`DELETE`/`PATCH` | ∅        |                                     |
| 414  | URI Too Long †             | `GET`/`PUT`/`DELETE`/`PATCH`  | ∅        |                                     |
| 415  | Unsupported Media Type     | `POST`/`PUT`/`PATCH`          | error    | Invalid payload media type          |
| 416  | Range Not Satisfiable      | `GET`                         | ∅        | Requested range out of bounds       |
| 417  | Expectation Failed         | `POST`/`PUT`/`PATCH`          | error    | `Expect: 100-continue` failed       |
| 422  | Unprocessable Entity       | `POST`/`PUT`/`PATCH`          | error    | Payload references invalid ID, etc. |
| 428  | Precondition Required      | `POST`/`PUT`/`DELETE`/`PATCH` | ∅        | `If-...` required                   |
| 429  | Too Many Requests          | any                           | error/∅  | Ratelimit hit                       |
| 431  | ‡                          | any                           | error/∅  |                                     |
| 500  | Server Error               | any                           | error/∅  | General server error                |
| 501  | Not Implemented †          | any                           | error    | Only in canary release              |
| 503  | Service Unavailable        | any                           | error    | Maintenance or overload             |
| 505  | HTTP Version Not Supported | any                           | error    | Maintenance or overload             |

Notes:

- † 400 (Bad Request) is an acceptable alternative.
- ‡ Request Header Fields Too Large
- _error_ for the body refers to a JSON payload containing pertinant information,
  such as the missing reference for a 422 (Unprocessable Entity).

Do not use 426 (Upgrade Required) and 101 (Switching Protocols).
Instead, use 505 (HTTP Version Not Supported) with a payload that lists the supported versions.

101 (Switching Protocols), 103 (Early Hints),
203 (Non-Authoritative Information), 205 (Reset Content), 208 (Already Reported), 226 (IM Used), WebDav’s 423 (Locked),
and 408 (Request Timeout)
are not normally seen as part of REST APIs and are strongly discouraged.

### Headers

#### Content types

Provide `Accept:` on non-`HEAD` requests – for example, `Content-Type: text/json`.
Similarly, provide `Content-Type:` on `POST` – for example, `Content-Type: text/json`.
Omit `charset` where it is not applicable, such with `Content-Type: text/json`. (JSON is always UTF-8).

#### Rate-limiting

Use [draft IETF rate-limiting headers](https://www.ietf.org/archive/id/draft-polli-ratelimit-headers-02.html):
`RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`.
These should always be included for 429 (Too Many Requests) responses
and MAY be included for other responses as well.

## Docker

Consider using a linter such as [hadolint](https://github.com/hadolint/hadolint).

### `ENV` commands

Break `ENV` commands into one line per command.
`ENV` no longer adds a layer in new Docker versions,
so there is no need to chain them on a single line.

### Labels

Use [Open Containers labels](https://github.com/opencontainers/image-spec/blob/master/annotations.md),
including:

- `org.opencontainers.image.version`
- `org.opencontainers.image.vendor`
- `org.opencontainers.image.title`
- `org.opencontainers.image.url`
- `org.opencontainers.image.documentation`

### Multistage builds

Where applicable, use a multistage build to separate _build-time_ and _runtime_ to keep containers slim.
For example, when using Maven, Maven is only needed to assemble, not to run.

Here, `maven:3-eclipse-temurin-21` is used as a base image, maven is used to compile and build a JAR artifact,
and everything but the JAR is discarded.
`eclipse-temurin:21` is used as the runtime base image, and only the JAR file is needed.

```Docker
FROM maven:3-eclipse-temurin-21 AS build
WORKDIR /root
RUN --mount=type=cache mvn package

FROM eclipse-temurin:21 AS run
ARG JAR_FILE=target/*.jar
COPY --from=build $JAR_FILE my-app.jar
EXPOSE 443
ENTRYPOINT java -jar my-app.jar
```

## Command-line tools

### Standard streams

As long as doing so sensible, CLI tools should read from stdin and write to stdout.
In either cases, they must direct logging messages to stderr, never to stdout.

### Arguments

Prefer named options over positional arguments.
Positional argument lists must be either fixed-length with less than 3 arguments, or arbitrary-length (infinite).
For arbitrary-length lists, all arguments must have the same meaning.
Tools should not accept more than 2 positional arguments if the arguments have different meanings.
The list below summarizes forms that are acceptable and not acceptable:

- ✅ `<tool> [<options>]`
- ✅ `<tool> [<options>] <arg-1>`
- ✅ `<tool> [<options>] <arg-1> <arg-2>`
- ✅ `<tool> [<options>] <args...>`
- ❌ `<tool> [<options>] <arg-1> <args...>` (positional and varargs)
- ❌ `<tool> [<options>] <arg-1> <arg-2> <arg-3>` (> 2 positional args)

Named options must be permitted before and after any positional arguments.
Tools that always read a single file and output a single file
can take both files as positional arguments.

Use double hyphens for long option names (e.g., `--user`).
Omit short names for options that are highly specific, rarely used, or dangerous.
Allow both `--option <arg>` and `--option=<arg>`.

Use standard option names:

- `--help`
- `--version` (output the version to stdout and exit)
- `--verbose` (and optionally `-v`)
- `--quiet` (and optionally `-q`)

## Bash

1. Use `#!/usr/bin/env bash`.
2. Set modes `-e`, `-u`, and `-o pipefail`.
3. Set `IFS=$'\n\t'` to stop splitting on spaces.
   Do this at the start of a script and after any time you set it a new value.
4. Accept a `--help` argument that writes  exit `0`.
   On errors, write an explanation (or just usage) to stderr, then exit `2`.
5. Send logging to stderr. Put `>&2` before the `echo`.
6. Always quote string variables, even those without spaces.
7. Use new Bash constructs like `[[` instead of `[`.

??? rationale

    By rule number:

    1. so that the correct `bash` is used
    2. Use
       - `-e` to end if any command exits with a nonzero code
       - `-u` to end if any undefined variable is referenced
       - `-o pipefail` to end if any command in a pipeline exits with a nonzero code
    3. `IFS=$'\n\t'` improves safety if a string with a space is not quoted
    4. [Shell bulletins use `2`](https://tldp.org/LDP/abs/html/exitcodes.html) to indicate misuse.
    5. Sending to stderr is to avoid it being interpreted as legitimate output when piping.
    6. An edit could later introduce a space.
    7. `[[` is much more powerful, and using `[` in addition is syntactically strange.

Rule 4 may be ignored if arguments are passed to another script via `$@`.
Put together, rules 1–4 look like this:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

default_arg2=asdf
_usage="Usage: ${0} arg1 [arg2=${default_arg1}]"
_description="Lorem ipsum dolor sit."

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	>&2 echo "${_usage}"        # (1)!
	>&2 echo "${_description}"
	exit 0
fi

write_usage() {
	>&2 echo "${_usage}"
	exit 2
}
if (( $# !=2 )); then
  write_usage
fi
```

1. Send usage information to stderr.

## Python

### Modules

Add all public members to `__all__`, declared immediately after the imports.
(Note that [mkdocstrings](https://github.com/mkdocstrings/mkdocstrings) requires this.)

### Formatting

[Black](https://github.com/psf/black) or the [Ruff formatter](https://docs.astral.sh/ruff/formatter/)
should be used, so don’t worry much about formatting.
Avoid add trailing commas so that Black can decide whether to keep code on one line or to chop it.

??? bug "Fix mistakes Black makes"

    Sometimes Black wraps lines in an awkward way.
    If this happens, either shorten the lines or break the code into multiple statements.
    For example:

    === "❌ Incorrect"

        ```python
        data = my_long_named_function_that_makes_the_line_too_long(
            data
        ).my_other_long_named_function_being_chained(1)
        ```

    === "✅ Correct – shorten function names"

        ```python
        data = my_shorter_function(data).my_other_shorter_function(1)
        ```

    === "✅ Also Correct – split up statements"

        ```python
        data = my_long_named_function_that_makes_the_line_too_long(data)
        data = data.my_other_long_named_function_being_chained(1)
        ```

### Classes

Use [pydantic](https://pydantic-docs.helpmanual.io/) or
[dataclasses](https://docs.python.org/3/library/dataclasses.html).
Most libraries should use dataclasses only to avoid a dependency on pydantic.
Use immutable types unless there’s a compelling reason otherwise.

??? Example

    === "dataclass"

        ```python
        from typing import Self
        from dataclasses import dataclass


        @dataclass(slots=True, frozen=True, order=True)
        class Cat:
            breed: str | None
            age: int
            names: frozenset[str]
        ```

    === "Pydantic"

        ```python
        from pydantic import BaseModel


        class Cat(BaseModel):
            breed: str | None
            age: int
            names: frozenset[str]

            class Config:
                frozen = True
        ```

    === "Pydantic (orjson)"

        ```python
        import orjson
        from pydantic import BaseModel


        def to_json(v) -> str:
            return orjson.dumps(v).decode(encoding="utf-8")


        def from_json(v: str):
            return orjson.loads(v).encode(encoding="utf-8")


        class Cat(BaseModel):
            breed: str | None
            age: int
            names: frozenset[str]

            class Config:
                frozen = True
                json_loads = from_json
                json_dumps = to_json
        ```

### Class members

Use `@abstractmethod` in favor of `@staticmethod`;
`@staticmethod` should only be used in the rare cases where `@abstractmethod` cannot be used.
As a general rule, prefer using a regular method over an `@abstractmethod`.

Sort class members in the following order.

1. `ClassVar`
2. attributes
3. `@staticmethod`
4. `@classmethod`
5. magic methods
6. `@property` methods, getters, and setters
7. regular methods
8. inner classes

Within each of the 8 types, order using three rules, in order of decreasing importance:

1. Pair getters and setters together, with the getter first.
2. Group dependent methods together such that callees are immediately below callers.
   That is, using a breadth-first search.
3. If there are two or more callees, arrange them in the order in which they appear in the caller.
4. List public, then private (`_xxx`), then dunder (`__xxx`).

### OS compatibility

Use `pathlib` instead of `os` wherever possible.
Always read and write text as UTF-8, and pass `encoding="utf-8"` (i.e., not `utf8` or `UTF-8`).

??? Example

    ```python
    from pathlib import Path

    directory = Path.cwd()
    (directory / "myfile.txt").write_text("hi", encoding="utf-8")
    ```

### Typing

Use typing annotations for both public APIs and internal components.
Annotate all module-level variables, class attributes, and functions.
Annotate both return types and parameters.
Annotate `self`, `cls`, `*args`, and `**kwargs` parameters.

??? rationale

    1. Documentation generators such as [mkdocstrings](https://github.com/mkdocstrings/mkdocstrings)
       (for mkdocs) can use type annotations to provide helpful hints for users;
       type annotations also aid reading source code.
    2. Linters, IDEs, and other tools use them to detect mistakes.
    3. Tools can use type annotations to detect incorrect types at runtime.
       This can be especially useful because duck typing prevents complete test coverage.
    4. For annotating `self` and `cls`: they are still subject to
       [Ruff’s ANN rules](https://docs.astral.sh/ruff/rules/#flake8-annotations-ann).

??? Example

    ```python
    from dataclasses import dataclass
    from typing import Any, Self, Unpack


    @dataclass(slots=True, frozen=True)
    class A(SomeAbstractType):
        value: int

        @classmethod
        def new_zero(cls: type[Self]) -> Self:
            return cls(0)

        def __add__(self: Self, other: Self) -> Self:
            return self.__class__(self.value + other.value)

        def add_sum(self: Self, *args: int) -> Self:
            return self.__class(self.value + sum(args))

        def delegate(self: Self, *args: Any, **kwargs: Unpack[tuple[str, Any]]) -> None:
            ...  # first do something special
            super().delegate(*args, **kwargs)
    ```

### Docstrings

Use [Google-style docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
as [mkdocstrings supports](https://mkdocstrings.github.io/griffe/docstrings/#google-style).

### Ruff rules

Use [Ruff]() to catch potential problems and bad practices.
Use **at least** the rules enabled in the
[cicd pyproject.toml](https://github.com/dmyersturnbull/cicd/blob/main/pyproject.toml).

To disable coverage of a line or block, use `# nocov` (not `# pragma: nocov`, etc.).

## Java

Refer to [Google’s Java style guide](https://google.github.io/styleguide/javaguide.html)
for _additional_ recommendations.

### Practices

#### Banned methods

Do not use `clone()` or `finalize()`.

#### Exceptions

Both checked and unchecked exceptions are fine.

#### Constructors

Constructors should map arguments transparently to fields.
If more complex functionality needs to happen to construct the object,
it should be moved to a factory, builder, or static factory method.

#### Optional types

Do not return `null` or accept `null` as an argument in public methods; Use `Optional<>` instead.
`null` is permitted in private code to improve performance.

#### Collections

Prefer collections to arrays unless doing so results in significant performance issues.

#### Immutability and records

Prefer immutable types, and use records for data-carrier-like classes.
Immutable classes must have only `final` fields and must not allow modification (except by reflection);
Constructors must make defensive copies, and getters must return defensive copies or views.

#### Getters, setters, and builder methods

Use `getXx()`/`setXx()` for mutable types but `Xx()` for immutable types:

- For _mutable_ types: name the getter `public double getAngle()`
- For _immutable_ types: name the getter `public double angle()`

Builder methods should follow the immutable convention (i.e., `angle()`).

#### `toString`

!!! tip

    IntelliJ can do this for you.
    Use the `StringJoiner` `toString` template.

Classes should override `Object.toString` and should normally use this template:

```java
public class Claz {

    private final String name;
    private final List<String> items;

    public Test(final String message, final List<String> items) {
        this.message = message;
        this.items = new ArrayList<>(items);
    }

    @Override public String toString() {
        return new StringJoiner(", ", Test.class.getSimpleName() + "[", "]")
            .add("name='" + name + "'")
            .add("items=" + items)
            .toString();
    }
}
```

#### `hashCode`

!!! tip

    IntelliJ can do this for you.
    Use the default `hashCode` template.

Most classes should override `hashCode` and `equals`.
`hashCode` should use this template:

```java
public class Claz {
    @Override public int hashCode() {
        return Objects.hash(field1, field2); // ...
    }
}
```

#### `equals`

!!! tip

    IntelliJ can do this for you.
    Use the provided `hashCode` and `equals` templates.

`equals()` may use either

- _universal equality_, where `equals()` returns `false` for incompatible types
- _multiversal equality_, where `equals()` throws an exception for incompatible types

<small>
In some languages, type safety of equality can be checked by the compiler.
[Scala 3 has type-safe multiversal equality](https://docs.scala-lang.org/scala3/book/ca-multiversal-equality.html).
</small>

Use `getClass()` to check type compatibility, **not** `instanceof`.
(For universal equality, only `getClass()` makes sense – and for multiversal equality, there is no difference.)
Additionally, subclasses of classes defining `equals()` should never add data or state.

##### Universal equality

For universal equality, use this template:

```java
public class Claz {

  @Override
  public int hashCode() {
    return Objects.hash(field1); // ...
  }

  @Override
  public boolean equals(final Object obj) {
    if (obj == this) {
      return true;
    }
    if (null == obj || getClass() != obj.getClass()) {
      return false;
    }
    final var o = (Claz) obj;
    return Objects.equals(message, o.message) && Objects.equals(items, o.items);
  }
}
```

??? tip "IntelliJ template for universal equality"

    Use this IntellJ template.
    Under Generate ➤ equals() and hashCode() ➤ ...
    make a new template called _universal_.

    <b>`equals()` template:</b>

    ```text
    #parse("equalsHelper.vm")
    @Override public boolean equals(Object obj) {
    if (obj == this) {
    return true;
    }
    if (null == obj || getClass() != obj.getClass()) {
    return false;
    }
    final var o = (${class.getName()}) obj;
    return ##
    #set($i = 0)
    #foreach($field in $fields)
    #if ($i > 0)
    && ##
    #end
    #set($i = $i + 1)
    #if ($field.primitive)
    #if ($field.double || $field.float)
    #addDoubleFieldComparisonConditionDirect($field) ##
    #else
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #end
    #elseif ($field.enum)
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #elseif ($field.array)
    java.util.Arrays.equals($field.accessor, obj.$field.accessor)##
    #else
    java.util.Objects.equals($field.accessor, obj.$field.accessor)##
    #end
    #end
    ;
    }
    ```

    <b>`hashCode()` template:</b>

    ```
    public int hashCode() {
    #if (!$superHasHashCode && $fields.size()==1 && $fields[0].array)
    return java.util.Arrays.hashCode($fields[0].accessor);
    #else
    #set($hasArrays = false)
    #set($hasNoArrays = false)
    #foreach($field in $fields)
    #if ($field.array)
    #set($hasArrays = true)
    #else
    #set($hasNoArrays = true)
    #end
    #end
    #if (!$hasArrays)
    return java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    );
    #else
    #set($resultName = $helper.getUniqueLocalVarName("result", $fields, $settings))
    #set($resultAssigned = false)
    #set($resultDeclarationCompleted = false)
    int $resultName ##
    #if($hasNoArrays)
    = java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if(!$field.array)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    #end
    );
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #elseif($superHasHashCode)
    = super.hashCode(); ##
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #foreach($field in $fields)
    #if($field.array)
    #if ($resultDeclarationCompleted)
    $resultName ##
    #end
    = ##
    #if ($resultAssigned)
    31 * $resultName + ##
    #end
    java.util.Arrays.hashCode($field.accessor);
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #end
    return $resultName;
    #end
    #end
    }
    ```

##### Multiversal equality

For multiversal equality, use this template:

```java
public class Claz {
    @Override public final int hashCode() {
        return Objects.hash(field1); // ...
    }
    @Override public final boolean equals(final Object obj) {
        if (o == this) {
            return true;
        }
        if (null == o) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            throw new IllegalArgumentException(
                "Type " + obj.getClass().getName()
                  + " is incompatible with "
                  + getClass().getName()
            );
        }
        final var o = (Claz) obj;
        return Objects.equals(message, o.message) && Objects.equals(items, o.items);
    }
}
```

??? tip "IntelliJ template for multiversal equality"

    Use this IntellJ template.
    Under Generate ➤ equals() and hashCode() ➤ ...
    make a new template called _universal_.

    <b>`equals()` template:</b>

    ```text
    #parse("equalsHelper.vm")
    @Override public final boolean equals(Object obj) {
    if (obj == this) {
    return true;
    }
    if (null == obj) {
    return false;
    }
    if (getClass() != obj.getClass()) {
    throw new IllegalArgumentException(
    "Type "
    + obj.getClass().getName()
    + " is incompatible with "
    + getClass().getName()
    );
    }
    final var o = (${class.getName()}) obj;
    return ##
    #set($i = 0)
    #foreach($field in $fields)
    #if ($i > 0)
    && ##
    #end
    #set($i = $i + 1)
    #if ($field.primitive)
    #if ($field.double || $field.float)
    #addDoubleFieldComparisonConditionDirect($field) ##
    #else
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #end
    #elseif ($field.enum)
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #elseif ($field.array)
    java.util.Arrays.equals($field.accessor, obj.$field.accessor)##
    #else
    java.util.Objects.equals($field.accessor, obj.$field.accessor)##
    #end
    #end
    ;
    }
    ```

    <b>`hashCode()` template:</b>

    ```
    public int hashCode() {
    #if (!$superHasHashCode && $fields.size()==1 && $fields[0].array)
    return java.util.Arrays.hashCode($fields[0].accessor);
    #else
    #set($hasArrays = false)
    #set($hasNoArrays = false)
    #foreach($field in $fields)
    #if ($field.array)
    #set($hasArrays = true)
    #else
    #set($hasNoArrays = true)
    #end
    #end
    #if (!$hasArrays)
    return java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    );
    #else
    #set($resultName = $helper.getUniqueLocalVarName("result", $fields, $settings))
    #set($resultAssigned = false)
    #set($resultDeclarationCompleted = false)
    int $resultName ##
    #if($hasNoArrays)
    = java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if(!$field.array)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    #end
    );
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #elseif($superHasHashCode)
    = super.hashCode(); ##
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #foreach($field in $fields)
    #if($field.array)
    #if ($resultDeclarationCompleted)
    $resultName ##
    #end
    = ##
    #if ($resultAssigned)
    31 * $resultName + ##
    #end
    java.util.Arrays.hashCode($field.accessor);
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #end
    return $resultName;
    #end
    #end
    }
    ```

#### `compareTo`

Immutable classes should implement `Comparable` and override `compareTo` as long as it is reasonable.
`compareTo` should be marked `final`.

#### Pattern matching

End every `case` block with a  `return` or `break` (no fall-through).

### Formatting

#### Indentation and wrapping

!!! tip

    IntelliJ can do this for you.
    Import the [IntelliJ formatter settings](intellij-style.xml).

Use 4 spaces for indentation and 4 for continuation (block indentation).
Limit lines to 120 characters.
Chop lines the way that
[Black wraps lines](https://black.readthedocs.io/en/stable/the_black_code_style/current_style.html#how-black-wraps-lines).
For example:

```java
public void extract(
    Mapping<String, Consumer<? extends Dessert<? extends Food>>> consumers,
    Supplier<Cake> deliciousCakeSupplier
) {
    // ...
}
```

#### Braces and line breaks

Use the original Java style guidelines:

1. Put opening braces on the same line
2. Keep `else` and `else if` on the same line (i.e., `} else {`).
   Similarly, keep `while` on the same line for do-while loops (i.e., `} while ()`).
3. Always uses braces and start a new line for `if`/`else`/`else if`, `switch`, and loop blocks.
4. Chained method calls may be either single-line or chopped into multiple lines.
  Keep the first call on the same line.
5. Place every annotation on its own line.

#### Blank lines

Add one blank line before each top-level declaration, excluding between fields.
List enum members on one line unless they explicitly call constructors
or extend past the 120-character max line width.
Single blank lines MAY be added in other places for clarity.
Do not use multiple consecutive line breaks.

#### Spacing

Follow
[Google’s horizontal whitespace](https://google.github.io/styleguide/javaguide.html#s4.6.2-horizontal-whitespace)
section, which are generally compatible with the IntelliJ formatter’s default settings.
Do not horizontally align.

#### Variable declarations

Declare variables when they are needed, not at the start of a block.
Always use `var` when initializing directly through a constructor or static factory method;
otherwise, use it if the type is either obvious or unimportant.
Only declare one variable per line; e.g., do not use `int var1, var2;`.
For array declarations, use `type[] name`, **not** `type name[]`.
In `main` methods, use `String... args`.

#### Comparisons

Always place constants on the right hand side.

#### Optional syntax

Omit any element or syntax that carries no semantic meaning.

Omit:

- All optional grouping parentheses
- Optional qualifiers with `this`, `super`
- Optional class name for static members of the same class
- The name of the outer class when accessing its members
- Unnecessary qualifier keywords, such as `abstract` methods in interfaces
- `.toString()`

However, do include:

- The name of the inner class when accessing its members
- `final` for parameters and local variables
- Annotation `(key = value)` instead of `(value)` for multi-argument annotations

#### Comments

Generally avoid end-of-line comments.
Also avoid multiline comments using `/*` and `*/`.
Instead, comment each line using `//`.

#### Encoding

Always encode source files as UTF-8.
Write non-ASCII characters without escaping, except for whitespace (excluding spaces)
and characters that are highly likely to confuse readers.

#### Naming

Follow [Google’s Java naming conventions](https://google.github.io/styleguide/javaguide.html#s5-naming).
Notably, treat acronyms as words – for example, `IoError`, **not** `IOError`
Name asynchronous methods (those that return a `CompletableFuture`) with the suffix `Async`; – for example,
`calculateAsync()`.

#### Member ordering

!!! tip

    IntelliJ can do this for you.
    Import the [IntelliJ formatter settings](intellij-style.xml).
    To acheive manually, choose the default order but select “group dependent methods together”
    and “keep getters and setters together”.

Sort members in the following order.

1. `static final` field
2. initializer block
3. `final` field
4. field
5. constructor
6. `static` method
7. method
8. getters and setters
9. `compareTo`, `hashCode`, `equals`, and `toString` (in order)
10. `enum`
11. `interface`
12. `static class`
13. `class`

!!! note

    Do not use non-`final` static fields.

Within each of the 13 types, order using 4 rules, in order of decreasing importance:

1. Pair getters and setters together, with the getter first.
2. Group dependent methods together such that callees are immediately below callers.
   That is, using a breadth-first search.
3. List overridden methods first.
4. Order by `public`, `protected`, default, then `private`.

## Scala

Where applicable, follow the [Java guidelines](#Java).

Always surround method bodies with curly braces.
In Scala 2.xx code: For void members, write `function(): Unit = {`, **not** `function() {`.

## JavaScript and TypeScript

### Practices

Where applicable, follow the [Java guidelines](#Java).

Always use strict mode, and generally use `===`, not `==`.
Use [`for`…`of`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of)
instead of `for`…`in`.

### Formatting

[Prettier](https://prettier.io/) will handle almost all formatting.
Just set the max line length to 120.

## SQL

### Formatting

!!! tip

    IntelliJ can do this for you.
    Import the [IntelliJ formatter settings](intellij-style.xml).

Use lowercase for keywords, aliases, function names, and columns, and table names.

Wrap at 120 characters and do not align horizontally.
Multiline statements should follow this indentation format:

```sql
select
    pet.name as name,
    pet.age as age,
    owner.name as owner
from
    pet
    inner join species on pet.species = species.id
    left join owner on pet.owner = owner.id
where
    owner.name = 'Berk'
    and species.name like 'Canis%'
;
```
