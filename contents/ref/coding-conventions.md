# Coding conventions

!!! abstract "How to use these docs"
    These docs are meant to be linked to.
    Include a link in your project's readme or _CONTRIBUTING.md_.
    E.g.,
    ```markdown
    See https://dmyersturnbull.github.io/ref/coding-conventions/
    but disregard the `security:` commit type, which we don't use.
    ```

    Or just link to individual sections; e.g.,
    ```markdown
    ### File names: Please see https://dmyersturnbull.github.io/ref/coding-conventions/#filesystem-and-uri-nodes
    ```

## Filesystem and URI nodes

Filesystem, URL, URI, and IRI naming:
See [Google’s filename conventions](https://developers.google.com/style/filenames).
Prefer kebab-case with one or more filename extensions: `[a-z0-9-]+(\.[a-z0-9]+)+`.
Always use a filename extension, and prefer `.yaml` for YAML and `.html` for HTML.
If necessary, `,`, `+`, and `~` can be used as word separators with reserved meanings.
Always use `/` as a path separator in documentation.

## Python

We use [Black](https://github.com/psf/black), so don’t worry much about formatting.

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

- Use records whenever possible.
  ```java
  public record Point(int x, int y) { }
  ```
- Prefer using factory methods, static factory methods, or builders over constructors.
  Constructors are much less explicit.
- Avoid using static members. Extract static members from your class and put them in a new class.
- Use streams where applicable. Prefer parallel streams over threads.
