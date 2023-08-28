# Coding conventions

!!! abstract "How to use these docs"
    These docs are meant to be linked to.
    Include a link in your project's readme or `CONTRIBUTING.md` file.
    E.g.,
    ```markdown
    See https://dmyersturnbull.github.io/ref/coding-conventions/
    but disregard the `security:` commit type, which we don't use.
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
Where possible, use `.yaml` for YAML, `.html` for HTML, and `.gz` for gzip.


## Documentation

See [Google’s documentation style guide](https://developers.google.com/style/).

Always use `/` as a path separator in documentation.
Denote directories with a trailing `/`.

### Markdown

Use an automated formatting tool run on pre-commit or prior to merges.
Break lines at the end of sentences.
If a line goes over 120 characters, break it after the last appropriate punctuation mark.
(For example, separate independent clauses).
Keeping each sentence on its own line dramatically improves diffs.

## Bash

1. Set modes:
     - `-e` to end if any command exits with a nonzero code
     - `-u` to end if any undefined variable is referenced
     - `-o pipefail` to end if any command in a pipeline exits with a nonzero code
2. Set `IFS=$'\n\t'` to stop splitting on spaces.
3. Always quote string variables.
4. Use new Bash constructs like `[[` instead of `[`.
5. Accept a `--help` argument, and have it exit `0`.
   On errors, write an explanation (or just usage) to stderr, then exit with a nonzero code.

Putting these all together:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
    echo "Usage: ${0}"
    echo "Writes an ERD of the schema in graphml to erd.graphml."
    echo "Requires environment vars DB_NAME, DB_USER, and DB_PASSWORD"
    exit 0
fi

if (( $# > 0 )); then
    >&2 echo "Usage: ${0}"
    exit 1
fi
```

## Python

Use [Black](https://github.com/psf/black), so don’t worry much about formatting.

### Classes

Use [pydantic](https://pydantic-docs.helpmanual.io/) or
[dataclasses](https://docs.python.org/3/library/dataclasses.html).
Use immutable types unless there’s a compelling reason otherwise.

=== "Pydantic"

    ```python
    import orjson
    from pydantic import BaseModel


    def to_json(v) -> str:
        return orjson.dumps(v).decode(encoding="utf8")


    def from_json(v: str):
        return orjson.loads(v).encode(encoding="utf8")


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
    from dataclasses import dataclass, KW_ONLY

    import orjson


    def to_json(v) -> str:
        return orjson.dumps(v).decode(encoding="utf8")


    def from_json(v: str):
        return orjson.loads(v).encode(encoding="utf8")


    # Note: Wherever possible, use `slots=True, frozen=True, order=True`
    @dataclass(slots=True, frozen=True, order=True)
    class Cat:
        breed: str | None
        age: int
        _: KW_ONLY
        names: frozenset[str]

        def json(self: Self) -> str:
            return to_json(self)
    ```

### OS compatibility

Use `pathlib` instead of `os` wherever possible.
Always read and write text as UTF-8.
Spell UTF-8 `utf-8`, not `utf8` or `UTF-8`.

```python
from pathlib import Path

directory = Path.cwd()
(directory / "myfile.txt").write_text("hi", encoding="utf-8")
```

## Java

- Do not put multiple statements on the same line.
- Use records whenever possible.
  ```java
  public record Point(int x, int y) { }
  ```
- Prefer using factory methods, static factory methods, or builders over constructors.
  Constructors are much less explicit.
- Avoid using static members. Extract static members from your class and put them in a new class.
- Use streams where applicable. Prefer parallel streams over threads.
