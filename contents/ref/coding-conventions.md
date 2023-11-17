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

    Use [this `.editorconfig`](https://raw.githubusercontent.com/dmyersturnbull/cicd/main/.editorconfig),
    as well as autoformatters such as [Prettier](https://prettier.io/) and
    [Black](https://github.com/psf/black) (or the [Ruff formatter](https://docs.astral.sh/ruff/formatter/)).
    to eliminate time spent formatting, avoid debates, and reduce commit diff sizes.
    Have these tools run via [pre-commit](https://pre-commit.com/) or pre-merge.

## Filenames

!!! tip

    This section can apply to naming of URI nodes, database IDs, and similar constructs.
    These are general guidelines.
    Alternatives should be used in some situations.
    For example, if camelCase is used in your JSON Schema, use camelCase for schema document filenames.

Prefer using kebab-case (e.g., `full-document.pdf`), treating `-` as a space.
Restrict to `-`, `.`, `[a-z]`, and `[0-9]`, unless there is a compelling reason otherwise.
If necessary, `--`, `+`, and `~` can be used as word separators with reserved meanings.
For example, `+` could denote join authorship in `mary-johnson+kerri-swanson-document.pdf`.

Always use one or more filename extensions.
(Name your license file `LICENSE.txt` or `LICENSE.md`.)
Where possible, use `.yaml` for YAML, `.html` for HTML, and `.jpeg` for JPEG.
In particular, **do not** use `.yml`, `.htm`, `.jpg`, or `.jfif`.

??? info "Rationale"

    The [official YAML extension is `.yaml`](https://yaml.org/faq.html).
    Moreover, the IANA media types are `application/yaml`, `text/html`, and `image/jpeg`.
    `.yml`, `.htm`, and `.jpg` are relics of DOS.
    Extensions are required because provide useful information; ommitting them can cause confusion.
    For example, a file named `info` could be a plain-text info document or a shell script that writes the info.
    Instead, write it as `info.txt` or `info.sh`.

## Comments

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

Comments must be maintained like all other elements of code.

## Language and grammar

!!! tip

    Apply these guidelines to both comments and documentation.

See [Google’s documentation style guide](https://developers.google.com/style/) for additional guidelines.

### Style

Remove text that is repetitive or superfluous.
Be direct. Use examples, diagrams, formal grammars, pseudocode, and mathematical expressions.
(Write English descriptions for diagrams and any other elements that are be inaccessible to screen readers.)

??? info "Use, utilize, usage, and utilization"

    Avoid the word <i>utilize</i>, which has lost any semantic distinction from <i>use</i>;
    Write <i>use</i> instead.

    - <i>utilization</i>: use only to describe _how much_ something is used
    - <i>usage</i>: use only to describe _how_ something is used or should be used.

Keep language accessible:
Introduce or explain jargon, favor simpler words, and replace idioms with literal phrasing.
Substitute long phrases with shorter ones.
Use singular <i>they</i> and other gender-neutral terms, and use inclusive language.
_Great documentation should never win awards for literature._
_Keep things simple and direct._

| ❌ Avoid                             | ✅ Preferred                     | Change                   |
|-------------------------------------|---------------------------------|--------------------------|
| <i>utilize</i>                      | <i>use</i>                      | simplify text            |
| <i>due to the fact that</i>         | <i>because</i>                  | simplify text            |
| <i>a great number of</i>            | <i>many</i>                     | simplify text            |
| <i>is able to</i>                   | <i>can</i>                      | simplify text            |
| <i>needless to say</i>              | (omit)                          | simplify text            |
| <i>it is important to note that</i> | <i>importantly,</i>             | simplify text            |
| <i>LRU</i>                          | <i>last recently used (LRU)</i> | introduce jargon         |
| <i>actress</i>                      | <i>actor</i>                    | use gender-neutral terms |
| <i>he or she</i>                    | <i>they</i>                     | use gender-neutral terms |
| <i>turned a blind eye to</i>        | <i>ignored</i>                  | avoid ableist language   |

### Spelling

Use American English spelling.

??? info "Rationale"

    American English is the [most widespread dialect](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5969760/),
    and it generally has more phonetic and shorter spellings.

### Grammar and punctuation

Use 1 space between sentences.

Use sentence case for titles and table headers (e.g., <i>This is a title</i>)
Capitalize the first word after a colon or semicolon only if it begins a valid sentence.
Observe a prescriptive distinction between
[which and that](https://owl.purdue.edu/owl/general_writing/grammar/that_vs_which.html).

## Markdown

!!! tip

    Where applicable, apply these guidelines to other documentation, not just Markdown.

### Line breaks

Break lines at the end of sentences.
If a line goes over 120 characters, break it after an appropriate punctuation mark.
For example, break up independent clauses.
(A series of very short sentences can be left on one line.)

??? info "Rationale"

    Keeping each sentence on its own line dramatically improves diffs.

### Semantic markup

Reserve Markdown’s `_`/`_` for emphasized text only;
For foreign words, names of books, technical terms, references to a word itself,
and other text that should be italicized,
use the [`<i>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i).
Though not preferred, backticks can be used instead of `<i></i>`.
Do not italicize ubiquitous foreign phrases such as
<i>in vivo</i>, <i>in sitro</i>, <i>in silico</i>, and <i>et al.</i>

??? info "Rationale"

    This is primarily to aid grammar checkers.
    For example, this is fine: `Say <i>and</i> and <i>or</i>`
    Whereas grammar checkers will think this has a duplicate <i>and</i>: `Say _and_ and _or_`.
    Foreign phrases are comparatively rare.
    Using `<i></i>` for them as well preserves the semantic distinction between
    the [`<em>` tag](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/em)
    and the [`<i>` tag](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i).

### Encoding

Write most non-ASCII characters as-is, not with entity references.
For example, write an en dash as `–`, not `&#x2013;`.

However, you may use hexadecimal entity references for:

- non-space whitespace characters
  (such as [no break space](https://www.compart.com/en/unicode/U+00A0), `&nbsp;`)
- punctuation that is highly likely to confuse anyone reading the source code
  (such as [soft hyphen](https://www.compart.com/en/unicode/U+00ad), `&#x00ad;`)
- characters that must be escaped for technical reasons

### Punctuation symbols

Use the correct Unicode characters for punctuation.
That includes:

- `’` for apostrophes
- `‘`, `’`, `“`, and `”` for quotation marks
- `–` (<i>en dash</i>) for numerical ranges (e.g., `5–10`)
- `—` (<i>em dash</i>) to separate a blockquote and its source
- `‒` (<i>figure dash</i>) in numerical formatting
- `−` (<i>minus sign</i>)
- `µ` (<i>micro sign</i>)

However, use <i>hyphen-minus</i> (U+002D) for hyphens, **not** <i>hyphen</i> (U+2010).

Use an en dash surrounded by spaces (` – `) to mark breaks in thoughts, **not** an em dash.
For example:

```markdown
An en dash – in contrast to an em dash – should be used here.
```

### Quotations

Place punctuation outside of quotation marks (British-style rules).
For example:

```markdown
Also write “hard”, “difficult”, or “strenuous”.
```

??? info "Rationale"

    This preserves the semantic difference between punctuation _inside_ versus _outside_ of quotations.
    This rule is always followed when using code in backticks, anyway.

Introduce code blocks with punctuation only where semantically valid.

For example, in the following block, use <i>then run</i>, not <i>then run:</i>.

````markdown
Then run

```
ps -a -x
```
````

Where it is semantically valid, introduce with a colon, not a comma.
For example:

```markdown
Mark Twain also said:

> When in doubt‚ tell the truth.
> This is a blockquote, which is ordinarily introduced by punctuation.
> For clarity, we introduce such blockquotes with colons.
> <i>— Mark Twain</i>
```

As seen above, use an em dash (—) set in `<i>`/`</i>` to cite a blockquote’s source.

??? info "Rationale"

    This rule preserves the semantics as much as possible.
    A colon is a visual signal that the prose goes with its following code block, reducing refactoring mistakes.

### Quantities

To format numbers and dimensioned quantities, use:

- A period (`.`) as the decimal marker
- A narrow no break space, ` ` (NNBSP / U+002D / `&#x202f;`) as the thousands separator
- A full space (` `) to separate magnitude and units

For example: <i>1 024.222 222 µm</i>.

Use SI units unless there is a strong reason not to.
Use `hour` or `hr`, `minute` or `min`, and `second`, `sec`, or `s` as abbreviations.

### Uncertainty measurements

State whether the values refer to standard error or standard deviation.
<i>SE</i> is an acceptable abbreviation for standard error;
<i>SD</i> is an acceptable abbreviation for standard deviation.

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

Always use `/` as a path separator in documentation.
Denote directories with a trailing `/`.
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

### Formatting

!!! note

    These formatting guidelines only apply to hand-crafted HTML.

#### Closing tags

Always close tags.
For example, use `<p>The end.</p>`, **not** `<p>The end.`.
Use trailing slashes for self-closing tags; for example,
write `<meta charset="utf-8" />`, **not** `<meta charset="utf-8">`.

??? info "Rationale"

    Requiring closing tags and trailing slashes improves readability and simplifies parsing.
    It enables XML parsing, obviates the need for custom parsers to remember which HTML tags are self-closing,
    and helps parsers emit errors that refer to specific tags.

#### `<html>`, `<head>`, and `<body>` elements

Always include these elements.

??? info "Rationale"

    The rules for
    [ommitting `<html>`, `<head>`, and `<body>`](https://html.spec.whatwg.org/#syntax-tag-omission)
    are complex and better ignored.

#### Quoting attributes

Always quote attributes with double quotes.

??? info "Rationale"

    This is the most widespread choice, and it tends to be easier for custom parsers.

#### Line wrapping

Wrap long tag declarations to 120 characters like this:

```html
<link
  rel="stylesheet"
  href="https://fonts.googleapis.com/css?family=IBM+Plex+Sans:regular,bold"
/>
```

??? info "Rationale"

    This style horizontally aligns the attribute names.
    More importantly, it is analogous to styles enforced by autoformatters like Prettier and Black,
    which are increasing in popularity.

### Attribute values

Use kebab-case for `id` and `name` values and for `data` keys and values.

Skip the `type` attribute  for scripts and stylesheets.
Instead, use `<link rel="stylesheet" href="..." />` for stylesheets
and `<script src="..." />` for scripts.

### Accessibility

Use the `alt` attribute for media elements, including `<img>`, `<video>`, `<audio>`, and `<canvas>`.

## HTTP APIs

### Status codes

This section applies to REST-like HTTP APIs.
Servers should only issue response codes in accordance with the following table.
_Note that some or even most of these might not apply!_
_For example, your server might not implement HTTP content negotiation._

!!! info

    404 (Not Found) is reserved for resources that _could_ exist but do not;
    attempts to access an invalid endpoint must always generate a 400 (Bad Request).

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
- <i>error</i> for the body refers to a JSON payload containing pertinant information,
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
- ❌ `<tool> [<options>] <arg-1> <args...>`
- ❌ `<tool> [<options>] <arg-1> <arg-2> <arg-3>`

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

??? info "Rationale"

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

    === "✅ Correct – shorten the function names"

        ```python
        data = my_shorter_function(data).my_other_shorter_function(1)
        ```

    === "✅ Also Correct – split into multiple statements"

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

1. `ClassVar`s
2. attributes
3. `@staticmethod`
4. `@classmethod`
5. magic methods
6. `@property` methods, getters, and setters
7. regular methods
8. inner classes

Within each of the 8 types, order using three rules, in order of decreasing importance:

1. Pair getters and setters together, with getters first.
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
Include any `self`, `cls`, `*args`, and `**kwargs` parameters.


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

??? info "Rationale"

    1. Documentation generators such as [mkdocstrings](https://github.com/mkdocstrings/mkdocstrings)
       (for mkdocs) can use type annotations to provide helpful hints for users;
       type annotations also aid reading source code.
    2. Linters, IDEs, and other tools use them to detect mistakes.
    3. Tools can use type annotations to detect incorrect types at runtime.
       This can be especially useful because duck typing prevents complete test coverage.
    4. For annotating `self` and `cls`: they are still subject to
       [Ruff’s ANN rules](https://docs.astral.sh/ruff/rules/#flake8-annotations-ann).

### Docstrings

Use [Google-style docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
as [supported by mkdocstrings](https://mkdocstrings.github.io/griffe/docstrings/#google-style).

## Java

Refer to [Google’s Java style guide](https://google.github.io/styleguide/javaguide.html)
for _additional_ recommendations.

### Practices

#### Constructors

Constructors should map arguments transparently to fields.
If more complex functionality needs to happen to construct the object,
it should be moved to a factory, builder, or static factory method.

#### Immutability and records

Prefer immutable types, and use records for data-carrier-like classes.
Immutable classes must have only `final` fields and must not allow modification (except by reflection);
Constructors must make defensive copies, and getters must return defensive copies or views.

#### Collections

Prefer collections to arrays unless doing so results in significant performance issues.

#### Getters and setters

Use `getXx()`/`setXx()` for mutable types but `Xx()` for immutable types:

- For _mutable_ types: name the getter `public double getAngle()`
- For _immutable_ types: name the getter `public double angle()`

#### `toString`

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

!!! tip

    This is called the `StringJoiner` template in IntelliJ.

#### `hashCode`

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

`equals()` may use either

- _universal equality_, where `equals()` returns `false` for incompatible types
- _multiversal equality_, where `equals()` throws an exception for incompatible types

!!! note

    In some languages, type safety of equality can be checked by the compiler.
    [Scala 3 has type-safe multiversal equality](https://docs.scala-lang.org/scala3/book/ca-multiversal-equality.html).

`instanceof` should be used to check type compatibility, **not** `getClass()`.
Additionally, subclasses of classes defining `equals()` should never add data or state.

##### Universal equality

For universal equality, use this template:

```java
public class Claz {
    @Override public final int hashCode() {
        return Objects.hash(field1); // ...
    }
    @Override public final boolean equals(final Object obj) {
        return this == obj
          || obj instanceof Claz && Objects.equals(field1, obj.field1); // ...
    }
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
        if (!(obj instanceof Claz)) {
            throw new IllegalArgumentException("Wrong type in '" + other + "'");
        }
        return this == obj ||
            Objects.equals(field1, obj.field1); // ...
    }
}
```

#### `compareTo`

Immutable classes should implement `Comparable` and override `compareTo` as long as it is reasonable.
`compareTo` should be marked `final`.

#### Pattern matching

End every `case` block with a  `return` or `break` (no fall-through).

### Formatting

#### Braces

Use the original Java style guidelines:

- Put opening braces on the same line
- Keep `else` and `else if` on the same line (i.e., `} else {`)
- Always uses braces for multiline `if`/`else`/`else if`, `switch`, and loop blocks
- Keep empty blocks on one line (i.e., `{}`), including for multi-block statements

#### Blank lines

Add one blank line before each top-level declaration, excluding between fields.
List enum members on one line unless they explicitly call constructors
or extend past the 120-character max line width.
Single blank lines MAY be added in other places for clarity.
Do not use multiple consecutive line breaks.

#### Spacing

Follow
[Google’s horizontal whitespace](https://google.github.io/styleguide/javaguide.html#s4.6.2-horizontal-whitespace)
section.
Do not horizontally align.

#### Variable declarations

Declare variables when they are needed, not at the start of a block.
Always use `var` when initializing directly through a constructor or static factory method;
otherwise, use it if the type is either obvious or unimportant.
For array declarations, use `type[] name`, **not** `type name[]`.
In `main` methods, use `String... args`.

#### Comparisons

Always place constants on the right hand side.
Omit optional grouping parentheses unless they greatly improve clarity.

#### Comments

Avoid end-of-line comments.

#### Indentation and wrapping

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

!!! tip

    IntelliJ can do this for you.
    Enable all “chop” options.

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

Sort members in the following order.

1. `static final` field
2. ~~`static` field~~ (non-`final` static fields should be avoided)
3. initializer block
4. `final` field
5. field
6. constructor
7. `static` method
8. method
9. `enum`
10. `interface`
11. `static class`
12. `class`

Within each of the 12 types, order using three rules, in order of decreasing importance:

1. Pair getters and setters together, with getters first.
2. Group dependent methods together such that callees are immediately below callers.
   That is, using a breadth-first search.
3. If there are two or more callees, arrange them in the order in which they appear in the caller.
4. List `public`, `protected`, default, then `private`.

!!! tip

    IntelliJ’s formatter can do this for you.
    Keep the default order but select “group dependent methods together”
    and  “keep getters and setters together”.
