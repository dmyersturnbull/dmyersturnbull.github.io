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

## File types

!!! note

    Use common sense with respect to these guidelines.
    For example, do not convert JPEG files to AVIF if there is a quality loss.

- Use AVIF or WEBP over other image formats,
  OGG and FLAC over other audio formats,
  and AV1 over other video formats.
- If compression is used, use a modern algorithm like [LZ4](https://github.com/lz4/lz4) (`.lz4`)
  or [ZSTD](https://github.com/facebook/zstd) (`.zst`).

## Documentation

See [Google’s documentation style guide](https://developers.google.com/style/).

Always use `/` as a path separator in documentation.
Denote directories with a trailing `/`.

### Markdown

Use an automated formatting tool run on pre-commit or prior to merges.

#### Line breaks

Break lines at the end of sentences.
If a line goes over 120 characters, break it after an appropriate punctuation mark.
For example, break up independent clauses.
This is not necessary for very short sentences, such as `Sure. Ok. Fine.`.

!!! info "Rationale"

    Keeping each sentence on its own line dramatically improves diffs.

#### Foreign words and referring to words themselves

When referring to a word itself, surround with `<i>`/`</i>`, not `_`/`_` or `*`/`*`.
Note: this is not needed for code elements (i.e., with `\``).
Do the same when using foreign words or phrases (if not in a quote block).
For example,

```markdown
- Say <i>and</i> and <i>or</i>
- `<i>stachelschwein für den Sieg</i>`
```

!!! note

    Ubiquitous foreign phrases, including <i>in vivo</i>, <i>in sitro</i>, <i>in silico</i>, and <i>et al.</i>
    should not be italicized (or surrounded with `<i>` and `</i>`.)

!!! info "Rationale"
    This is to aid grammar checkers.
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

#### Punctuation

Place punctuation outside of quotation marks (British-style rules).
For example:

```markdown
Also write "hard", "difficult", or "strenuous".
```

!!! info "Rationale"
    This preserves the semantic difference between punctuation _inside_ versus _outside_ of quotations.
    This rule is always followed when using `\`code\`` anyway.

Introduce code blocks with punctuation only where semantically valid.

For example:

```markdown
Then run

`
ps -a -x
`
```

Where it is valid, introduce with a colon, not a comma.

```markdown
Mark Twain also said:

> When in doubt‚ tell the truth.
```

!!! info "Rationale"

    This rule preserves the semantics as much as possible.
    A colon is a visual signal that the prose goes with its following code block, reducing refactoring mistakes.

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

### OS compatibility

Use `pathlib` instead of `os` wherever possible.
Always read and write text as UTF-8, and pass `encoding="utf-8"` (i.e., not `utf8` or `UTF-8`).

```python
from pathlib import Path

directory = Path.cwd()
(directory / "myfile.txt").write_text("hi", encoding="utf-8")
```

## Java

- Use 4 spaces for indentation.
- Do not put multiple statements on the same line.
- Use records whenever possible.
  ```java
  public record Point(int x, int y) { }
  ```
- Prefer using factory methods, static factory methods, or builders over constructors.
  Constructors are much less explicit.
- Avoid using static members. Extract static members from your class and put them in a new class.
- Use streams where applicable. Prefer parallel streams over threads.
