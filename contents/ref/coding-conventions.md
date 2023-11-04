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

    Use [this `.editorconfig`](https://raw.githubusercontent.com/dmyersturnbull/cicd/main/.editorconfig).
    Use [Black](https://github.com/psf/black), [Prettier](https://prettier.io/), and other formatters
    to eliminate time spent formatting, circumvent debates about formatting, and reduce diff sizes.

## Filenames

!!! info
    These are general guidelines. For some situations, it may be better to ignore them and create your own.
    For example, if camelCase is used in your JSON Schema, use camelCase for schema document filenames.

!!! tip
    This section can apply to naming of URI nodes, database IDs, and similar constructs.

Prefer using kebab-case (e.g., `full-document.pdf`), treating `-` as a space.
Restrict to `-`, `.`, `[a-z]`, and `[0-9]`, unless there is a compelling reason otherwise.
If necessary, `--`, `+`, and `~` can be used as word separators with reserved meanings.
For example, `+` could denote join authorship in `mary-johnson+kerri-swanson-document.pdf`.

Always use one or more filename extensions.
(Name your license file `LICENSE.txt` or `LICENSE.md`.)
Where possible, use `.yaml` for YAML, `.html` for HTML, and `.jpeg` for JPEG.
In particular, **do not** use `.yml`, `.htm`, `.jpg`, or `.jfif`.

!!! info "Rationale"

    The [official YAML extension is `.yaml`](https://yaml.org/faq.html).
    Moreover, the IANA media types are `application/yaml`, `text/html`, and `image/jpeg`.
    `.yml`, `.htm`, and `.jpg` are relics of DOS.
    Extensions are required because provide useful information; ommitting them can cause confusion.
    For example, a file named `info` could be a plain-text info document or a shell script that writes the info.
    Instead, write it as `info.txt` or `info.sh`.

## File types

!!! note

    Use common sense with respect to these guidelines.
    For example, do not convert JPEG files to AVIF if there is a quality loss.

- _Use open standards:_ Use AVIF or WEBP over other image formats, OGG and FLAC over other audio formats,
- AV1 over other video formats, and webm over other MKV.
- _Use simpler formats:_
  Use Markdown
- _Use modern compression:_
  Prefer modern algorithms like [LZ4](https://github.com/lz4/lz4) (`.lz4`)
  and [ZSTD](https://github.com/facebook/zstd) (`.zst`).

## Documentation (general)

See [Google’s documentation style guide](https://developers.google.com/style/).

Always use `/` as a path separator in documentation.
Denote directories with a trailing `/`.

## Markdown

Use an automated formatting tool run on pre-commit or prior to merges.

### Line breaks

Break lines at the end of sentences.
If a line goes over 120 characters, break it after an appropriate punctuation mark.
For example, break up independent clauses.
This is not necessary for very short sentences, such as `Sure. Ok. Fine.`.

!!! info "Rationale"

    Keeping each sentence on its own line dramatically improves diffs.

### Semantic markup

Reserve Markdown’s `_`/`_` for emphasized text only;
use the [`<i>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i)
for foreign words, names of books, technical terms, references to a word itself,
and other text that should be italicized.

!!! note

    Ubiquitous foreign phrases, including <i>in vivo</i>, <i>in sitro</i>, <i>in silico</i>, and <i>et al.</i>
    should not be italicized.
    (They are italicized here to refer to the words themselves.

!!! info "Rationale"
    This is primarily to aid grammar checkers.
    For example, this is fine:

    ```markdown
    Say <i>and</i> and <i>or</i>
    ```

    Whereas grammar checkers will think this has a duplicate <i>and</i>:

    ```markdown
    Say _and_ and _or_
    ```

    Foreign phrases are comparatively rare.
    Using `<i></i>` for them as well preserves the semantic distinction between
    the [`<em>` tag](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/em)
    and the [`<i>` tag](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i).

### Encoding

Write most non-ASCII characters as-is, not with entity references.
For example, write an en dash as `–`, not `&#x2013;`.

However, you MAY use hexadecimal entity references for:

- non-space whitespace characters
  (such as [no break space](https://www.compart.com/en/unicode/U+00A0), `&nbsp;`)
- punctuation that is highly likely to confuse anyone reading the source code
  (such as [soft hyphen](https://www.compart.com/en/unicode/U+00ad), `&#x00ad;`)
- characters that must be escaped for technical reasons

Use the correct Unicode characters for punctuation.
That includes:

- `’` for apostrophes
- `‘`, `’`, `“`, and `”` for quotation marks
- `–` (<i>en dash</i>) for numerical ranges (e.g., `5–10`)
- `—` (<i>em dash</i>) or ` – ` to mark breaks in thought
- `‒` (<i>figure dash</i>) in numerical formatting
- `−` (<i>minus sign</i>)
- `±` (<i>plus-minus sign</i>)
- `µ` (<i>micro sign</i>)
- (however, use <i>hyphen-minus</i> (U+002D) for hyphens, not <i>hyphen</i> (U+2010).

To format numbers, use:

- `.` as the decimal marker
- ` ` (narrow no break space, NNBSP (U+002D / `&#x202f;`)) as the thousands separator
- A full space (` `) to separate magnitude and units

For example: <i>1 024.222 222 µm</i>.
Prefer SI units, and use `hour` or `hr`, `minute` or `min`, and `second`, `sec`, or `s` as abbreviations.

### Punctuation

Place punctuation outside of quotation marks (British-style rules).
For example:

```markdown
Also write “hard”, “difficult”, or “strenuous”.
```

!!! info "Rationale"
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
```

!!! info "Rationale"

    This rule preserves the semantics as much as possible.
    A colon is a visual signal that the prose goes with its following code block, reducing refactoring mistakes.

### Formatting specific types

For dates and times, use [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339).
For example: `2023-11-02T14:55:00 -08:00`.
Note that the UTC offset is written with a hyphen, not a minus sign.

For filesystem trees, use refer to the
[research projects guide’s example](https://dmyersturnbull.github.io/guide/research-projects/#example).

## HTML

The rules for Markdown apply to HTML.
Also follow [Google’s HTML/CSS style guide](https://google.github.io/styleguide/htmlcssguide.html).

### Tags

Always close tags.
For example, use `<p>The end.</p>`, not `<p>The end.`.
Use trailing slashes in self-closing tags; for example, `<meta charset="utf-8" />`, not `<meta charset=utf-8">`.

!!! info "Rationale"
    Requiring closing tags and trailing slashes improves readability and simplifies parsing.
    It enables XML parsing, obviates the need for custom parsers to remember which HTML tags are self-closing,
    and helpers parsers emit errors that refer to specific tags.

Wrap long tag declarations to 120 characters like this:
```html
<link
  rel="stylesheet"
  href="https://fonts.googleapis.com/css?family=IBM+Plex+Sans:regular,bold"
>
```

## HTTP APIs

### Status codes

This section applies to REST-like HTTP APIs.
Servers should only issue response codes in accordance with the following table.
_Note that some or even most of these might not apply!_
_For example, your server might not implement HTTP content negotiation, or even `POST`._

| code | name                       | methods                       | Body     | use case                            |
|------|----------------------------|-------------------------------|----------|-------------------------------------|
| 100  | Continue                   | `POST`/`PUT`/`PATCH`          | ∅        | `Expect: 100-continue` ok           |
| 200  | OK                         | `GET`/`HEAD`/`PATCH`          | resource |                                     |
| 201  | Created                    | `POST`/`PUT`                  | resource |                                     |
| 202  | Accepted                   | `POST`                        | ∅        |                                     |
| 204  | No Content                 | `GET`                         | ∅        | Resource not found                  |
| 204  | No Content                 | `DELETE`                      | ∅        | Successful deletion                 |
| 200  | Partial Content            | `GET`                         | partial  | Range was requested                 |
| 303  | See Other †                | any                           | ∅        | Removed endpoint has alternative    |
| 304  | Not Modified               | `GET`/`HEAD`                  | ∅        | `If-None-Match` matches             |
| 308  | Permanent Redirect †       | any                           | ∅        | Endpoint moved                      |
| 400  | Bad Request                | any                           | ∅        | Invalid endpoint                    |
| 401  | Unauthorized               | any                           | ∅        | Not authenticated                   |
| 403  | Forbidden                  | any                           | ∅        | Insufficient privileges             |
| 404  | Not Found                  | `DELETE`/`PATCH`              | ∅        | Resource does not exist             |
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

- † These responses are encouraged, but a 400 (Bad Request) is an acceptable alternative.
- ‡ Request Header Fields Too Large

Do not use 426 (Upgrade Required) and 101 (Switching Protocols).
Instead, use 505 (HTTP Version Not Supported) with a payload that lists the supported versions.

101 (Switching Protocols), 103 (Early Hints),
203 (Non-Authoritative Information), 205 (Reset Content), 208 (Already Reported), 226 (IM Used), WebDav’s 423 (Locked),
and 408 (Request Timeout)
are not normally seen as part of REST APIs and are not recommended.

### Headers

#### Content types

**✅ DO:**
Provide `Accept:` on non-`HEAD` requests. For example, `Content-Type: text/json`.

**✅ DO:**
Provide `Content-Type:` on `POST`. For example, `Content-Type: text/json`.

**❌ DO NOT:**
Include a `charset` parameter where it is not applicable, such with `Content-Type: text/json` (which is always UTF-8).

#### Rate-limiting

Use [draft IETF rate-limiting headers](https://www.ietf.org/archive/id/draft-polli-ratelimit-headers-02.html):
`RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`.

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

!!! info "Rationale"

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

Use [Black](https://github.com/psf/black), so don’t worry much about formatting.
If Black wraps lines in an awkward way, either shorten the lines or break it into multiple statements to circumvent.
For example:

```python
data = my_long_named_function_that_makes_the_line_too_long(
    data
).my_other_long_named_function_being_chained(1)
```

Then rename the functions:

```python
data = my_shorter_function(data).my_other_shorter_function(1)
```

Or rewrite into multiple statements:

```python
data = my_long_named_function_that_makes_the_line_too_long(data)
data = data.my_other_long_named_function_being_chained(1)
```

### Classes

Use [pydantic](https://pydantic-docs.helpmanual.io/) or
[dataclasses](https://docs.python.org/3/library/dataclasses.html).
Use immutable types unless there’s a compelling reason otherwise.

=== "Pydantic"

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

=== "dataclass"

    ```python
    from typing import Self
    from dataclasses import dataclass

    import orjson


    def to_json(v) -> str:
        return orjson.dumps(v).decode(encoding="utf-8")


    def from_json(v: str):
        return orjson.loads(v).encode(encoding="utf-8")


    # Note: Wherever possible, use `slots=True, frozen=True, order=True`
    @dataclass(slots=True, frozen=True, order=True)
    class Cat:
        breed: str | None
        age: int
        names: frozenset[str]

        def json(self: Self) -> str:
            return to_json(self)
    ```

### Member ordering

Sort class members in the following order.

1. `ClassVar`s
2. attributes
3. `@staticmethod` _(note: generally avoid these)_
4. `@classmethod`
5. magic methods
6. regular methods
7. inner classes

Within each section, sort either alphabetically or such that higher-level members are above lower-level ones.

### OS compatibility

Use `pathlib` instead of `os` wherever possible.
Always read and write text as UTF-8, and pass `encoding="utf-8"` (i.e., not `utf8` or `UTF-8`).

```python
from pathlib import Path

directory = Path.cwd()
(directory / "myfile.txt").write_text("hi", encoding="utf-8")
```

## Java

Refer to [Google’s Java style guide](https://google.github.io/styleguide/javaguide.html)
for _additional_ recommendations.

### Constructors

Constructors should map arguments transparently to fields.
If more complex functionality needs to happen to construct the object,
it should be moved to a factory, builder, or static factory method.

### Formatting

#### Braces

Use the original Java style guidelines:

- Put opening braces on the same line
- Keep `else` and `else if` on the same line (i.e., `} else {`)
- Always uses braces for `if`/`else`/`else if`, `switch`, and loop blocks
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
and
[horizontal alignment](https://google.github.io/styleguide/javaguide.html#s4.6.3-horizontal-alignment)
sections.

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
Wrap lines the way that
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

#### Encoding

Always encode source files as UTF-8.
Write non-ASCII characters without escaping, except for whitespace (excluding spaces)
and characters that are highly likely to confuse readers.

#### Member ordering

Sort members in the following order.

1. `static final` field
2. `static` field _(note: non-`final` static fields should be avoided)_
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

Within each section, sort by `public`, `protected`, default, then `private`.
Then, sort either alphabetically or such that higher-level members are above lower-level ones.

### Other things

- Do not use fall-through `case` blocks.
- Where possible, prefer collections to arrays.
- Use records where applicable.
