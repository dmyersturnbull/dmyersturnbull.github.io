# Python conventions

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Modules

Add all public members to `__all__`, declared immediately after the imports.
(Note that [mkdocstrings](https://github.com/mkdocstrings/mkdocstrings) requires `__all__`.)

Use `mainpkg/__init__.py` to `import` the most important classes.
Do not set `__author__` or similar fields, but do set `mainpkg/__version__`.

## Formatting

The [Ruff formatter](https://docs.astral.sh/ruff/formatter/)
– which is equivalent to [Black](https://github.com/psf/black)
– should be used, so don’t worry much about formatting.
Avoid add trailing commas so that Black can decide whether to keep code on one line or to chop it.

Sometimes Ruff/Black wraps lines in awkwardly, by prioritizing argument lists over call chains.
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

## Pydantic and dataclasses

Use [pydantic](https://pydantic-docs.helpmanual.io/) or
[dataclasses](https://docs.python.org/3/library/dataclasses.html).
Most libraries should use only dataclasses to avoid a dependency on pydantic.
Use immutable types unless there’s a compelling reason otherwise.

??? example

    === "dataclass"

        ```python
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

## Abstract base classes

Inherit directly from abstract base classes in
[`collections.abc`](https://docs.python.org/3/library/collections.abc.html)
rather than using `metaclass=`.

```python
from collections.abc import Sequence, MutableSequence
from dataclasses import dataclass
from typing import Literal, Self


@dataclass(slots=True, frozen=True)
class AxisTicks(Sequence[int]):

    orientation: Literal["x"] | Literal["y"]
    items: Sequence[int]

    def __getitem__(selfself, i: int) -> int:
        return self.items[i]

    def __len__(selfself) -> int:
        return len(self.items)


# Error!
# dataclasses.FrozenInstanceError: cannot assign to field 'orientation'
AxisTicks(orientation="x", items=[1, 3, 5])
a.orientation = "y"
```

## Class members

### IoC

**Apply inversion of control, and do so ruthlessly.**

### `@staticmethod` and `@abstractmethod`

Use `@staticmethod` and `@abstractmethod` only for utilities that are specific to their class.
Replace static factory `@abstractclass` methods with property factories,
to separate the creation of an object from its API.

Never create utility classes with static (`@staticmethod` or `@abstractmethod`) methods;
use valid OOP instead.

=== "❌ Bad design"

    ```python
    class Utils:
        @abstractmethod
        def method(cls):
            ...
    ```

=== "✅ Fixed design"

    ```python
    class Utils:
        def method(self):
            ...
    utils = Utils()  # wherever it's needed
    ```

### Ordering members

Sort class members in the following order.
(These rules are copied from semi-official sources.)

1. `ClassVar`
2. attributes
3. `@staticmethod`
4. `@classmethod`
5. magic methods
6. `@property` methods, getters, and setters
7. regular methods
8. inner classes

Within each of the 8 types, order by, in order of decreasing importance:

1. Pairing getters and setters together, with the getter first.
2. Listing public, then private (`_xxx`), then dunder (`__xxx`).

## OS compatibility

Use `pathlib` instead of `os` wherever possible.
Always read and write text as UTF-8, and pass `encoding="utf-8"` (i.e. not `utf8` or `UTF-8`).

??? example

    ```python
    from pathlib import Path

    directory = Path.cwd()
    (directory / "myfile.txt").write_text("hi", encoding="utf-8")
    ```

## Typing

??? rationale

    1. Documentation generators such as [mkdocstrings](https://github.com/mkdocstrings/mkdocstrings)
       (for mkdocs) can use type annotations to provide helpful hints for users;
       type annotations also aid reading source code.
    2. Linters, IDEs, and other tools use them to detect mistakes.
    3. Tools can use type annotations to detect incorrect types at runtime.
       This can be especially useful because duck typing prevents complete test coverage.
    4. For annotating `self` and `cls`: they are still subject to
       [Ruff’s ANN rules](https://docs.astral.sh/ruff/rules/#flake8-annotations-ann).

Use typing annotations for both public APIs and internal components.
Annotate all module-level variables, class attributes, and functions.
Annotate both return types and parameters.
Annotate `self`, `cls`, `*args`, and `**kwargs` parameters.

??? example

    ```python
    from dataclasses import dataclass
    from typing import Any, Self, Unpack


    @dataclass(slots=True, frozen=True)
    class A(SomeAbstractType):
        value: int

        @classmethod
        def new_zero(cls) -> Self:
            return cls(0)

        def __add__(selfself, otherself) -> Self:
            return self.__class__(self.value + other.value)

        def add_sum(selfself, *args: int) -> Self:
            return self.__class(self.value + sum(args))

        def delegate(selfself, *args: Any, **kwargs: Unpack[tuple[str, Any]]) -> None:
            ...  # first do something special
            super().delegate(*args, **kwargs)
    ```

### Collection types

In Python 3.9, [PEP 585](https://peps.python.org/pep-0585/) enabled type parameterization for the concrete types
`list`, `set`, `frozenset`, `dict`, `tuple`, and `type` and deprecated their
[aliases in `typing`'](https://docs.python.org/3/library/typing.html#aliases-to-types-in-collections).

It also enabled parameterization on types from `collections.abc` like `Set`,
and made corresponding types in `typing` deprecated aliases.
For example,
`typing.AbstractSet` is a deprecated alias to `collections.abc.Set`,
`typing.MutableSet` is a deprecated alias to `collections.abc.MutableSet`,
and `typing.Set` is a deprecated alias to `set`.
Similarly, `typing.Sequence` is a deprecated alias to `collections.abc.Sequence`,
and `typing.List` is a deprecated alias to `list`.
`typing.Mapping` is a deprecated alias to `collections.abc.Mapping`,
and `typing.Dict` is a deprecated alias to `dict`.

- To annotate a parameter, `Sequence` is usually better than the concrete type `list`,
  but `list` is so ubiquitous that it’s acceptable.
- Using `Mapping`, at least for parameters, is usually better than using `dict`.
- For parameters, `collections.abc.Set` is almost always better than `set`.
  Although `set[str] | frozenset[str]` is comparable to `Set[str]`,
  the latter is more general, as well as shorter and more obvious.

??? info "Demonstrating `set`, `frozenset`, `MutableSet`, and `Set`"

    ```python
    from collections.abc import MutableSet, Set

    isinstance(set(), set)  # True
    isinstance(set(), MutableSet)  # True
    isinstance(set(), Set)  # True

    isinstance(frozenset(), set)  # False
    isinstance(frozenset(), MutableSet)  # False
    isinstance(frozenset(), Set)  # True
    ```

#### Collection hierarchy

Refer to this diagram.
Types like `KeysView` and `defaultdict` are rarely useful for typing.

```mermaid
stateDiagram
  direction RL
  classDef abc font-style:italic,stroke:#999,stroke-width:2px,stroke-dasharray: 5;
classDef concrete stroke:#999,stroke-width:2px;
Container --> Iterable:::abc
Sized:::abc --> Iterable:::abc
Collection:::abc --> Iterable:::abc
Iterator:::abc --> Iterable:::abc
Reversible:::abc --> Iterable:::abc
Sequence:::abc --> Reversible:::abc
Collection:::abc --> Container:::abc
Callable:::abc --> Container:::abc
Collection:::abc --> Sized:::abc
Set:::abc --> Collection:::abc
Mapping:::abc --> Collection:::abc
Sequence:::abc --> Collection:::abc
ByteString:::abc --> Collection:::abc
MappingView:::abc --> Collection:::abc
MutableMapping:::abc --> Mapping:::abc
MutableSequence:::abc --> Sequence:::abc
MutableSet:::abc --> Set:::abc
ItemsView:::abc --> MappingView:::abc
ValuesView:::abc --> MappingView:::abc
KeysView:::abc --> MappingView:::abc
MutableSequence:::abc --> Sequence:::abc
str:::concrete --> Sequence
tuple:::concrete --> Sequence
range:::concrete --> Sequence
list:::concrete --> MutableSequence
bytearray:::concrete --> MutableSequence
deque:::concrete --> MutableSequence
frozenset:::concrete --> Set
set:::concrete --> MutableSet
bytes:::concrete --> ByteString
memoryview:::concrete --> ByteString
dict:::concrete --> MutableMapping
defaultdict:::concrete --> MutableMapping
Counter:::concrete --> MutableMapping
```

## Docstrings

Use [Google-style docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
as [mkdocstrings supports](https://mkdocstrings.github.io/griffe/docstrings/#google-style).

## Ruff rules

Use [Ruff](https://docs.astral.sh/ruff/) to catch potential problems and bad practices.
Use **at least** the rules enabled in the
[tyranno-sandbox pyproject.toml](https://github.com/dmyersturnbull/tyranno-sandbox/blob/main/pyproject.toml).
