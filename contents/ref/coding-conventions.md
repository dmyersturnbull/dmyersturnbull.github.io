# Conventions

## Filesystem and URI nodes

Filesystem, URL, URI, and IRI naming:
See [Google’s filename conventions](https://developers.google.com/style/filenames).
Prefer kebab-case with one or more filename extensions: `[a-z0-9-]+(\.[a-z0-9]+)+`.
Always use a filename extension, and prefer `.yaml` for YAML and `.html` for HTML.
If necessary, `,`, `+`, and `~` can be used as word separators with reserved meanings.
Always use `/` as a path separator in documentation.

## Python classes

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
    import orjson
    from dataclasses import dataclass, KW_ONLY


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

        def json(self) -> str:
            return to_json(self)
    ```
