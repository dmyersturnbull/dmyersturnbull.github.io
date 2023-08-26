<style>
red { color: Red }
orange { color: Orange }
green { color: Green }
blue { color: Blue }
teal { color: Teal }
purple { color: Purple }
</style>

# Software testing

## Layers of tests

Some literature distinguishes between validation & verification,
or between [functional](https://en.wikipedia.org/wiki/Functional_testing)
and [non‐functional](https://en.wikipedia.org/wiki/Non-functional_testing) testing.

| V&V          | F/NF                | Confirms that...                                        |
|--------------|---------------------|---------------------------------------------------------|
| verification | functional (F)      | software does what it says (we built it right)          |
| validation   | non-functional (NF) | software does what it should (we built the right thing) |

We can also consider testing in layers.

| Layer           | Type | Purposes                                             | Example types of test            |
|-----------------|------|------------------------------------------------------|----------------------------------|
| 0 - Static      | F    | Constrain test surface                               | compilation, type checking       |
| 1 - Unit        | F    | Verify components work in isolation; localize issues | unit                             |
| 2 - Integration | F    | Verify components work together                      | integration                      |
| 3 - System      | F    | Verify entire system works                           | system, regression, sanity       |
| 4 - Acceptance  | NF   | Validate that software meets requirements            | security, performance, usability |

Where does an integration test end and a system test begin?
It doesn’t matter, as long as you distinguish between the extremes and have both.

## Layer 0 - Static

Just because your code compiled doesn't mean it's correct.
So, a static type system isn't a replacement for tests.
However, it _does_ constrain the input surface, which makes % test coverage meaningful.

### Constrain input surface

Suppose you invented a fancy matrix algorithm, and you're implementing it in three languages:

=== "Python"
    ```python
    class MyAlgorithm:
        def calculate(matrix_a, matrix_b):
            """
            Calculates on matrices a and b.

            Arguments:
                matrix_a: A matrix
                matrix_b: A second matrix

            Returns:
                A matrix
            """
            # some fancy things...
            #
            return matrix_a * matrix_b
    ```

=== "Scala"
    ```scala
    import breeze.linalg.Matrix;
    class MyAlgorithm {
      calculate(matrixA: Matrix, matrixB: Matrix): Matrix = {
        // some fancy things...
        matrixA * matrixB
      }
    ```

=== "Java"
    ```java
    import org.nd4j.linalg.api.ndarray.IndArray;
    public class MyAlgorithm {
      public Matrix calculate(IndArray matrixA, IndArray matrixB) {
        // some fancy things...
        return matrixA.mmuli(matrixB)
      }
    ```

In the Java and Scala examples, it's clear how to test your `calculate` function.
In Scala, the function takes two [Breeze Matrices](http://www.scalanlp.org/api/breeze/#breeze.linalg.Matrix)
and outputs a number.

In Python, it takes two matrices.
Your tests pass because the library you're using defines `*` between matrices as matrix multiplication.
But your users may not be using that library.
[Numpy `ndarray`](https://numpy.org/doc/stable/reference/generated/numpy.ndarray.html) does element-wise multiplication.
If your user calls `calculate(ndarray_a, ndarray_2)` for square matrices, they'll get a valid-looking but wrong answer.

**In fact, it is not possible to prevent these problems**.
That is, unless you detail the behavior of each input type:

```python
def calculate(matrix_a, matrix_b):
    """
    Calculates on matrices a and b.

    Arguments:
        matrix_a: A matrix; must define the following methods:
                  `__mul__`: Matrix multiplication
                  `__add__`: Elementwise addition
                  `__len__`: Number of rows
                  `__item__`: Takes a tuple (row, column) and returns the value
                  ...
        matrix_b: A second matrix with the same methods

    Returns:
        A matrix
    """
    # some fancy things...
    #
    return matrix_a * matrix_b
```

!!! aside "Aside: a criticism of duck typing"

    This really wasn't your fault; you were writing Pythonic code and following duck typing.
    The problem with the duck typing philosophy is that your "quack" function could do either of these:

    === "Quack Type 1"

        ```python
        from __future__ import annotations
        from dataclasses import dataclass


        @dataclass(frozen=True, slots=True)
        class Duck:
            name: str
            quacking: bool = False

            def quack(self) -> Duck:
                return Duck(quacking=True)
        ```

    === "Quack Type 2"

        ```python
        from dataclasses import dataclass


        @dataclass()
        class Duck:
            name: str
            quacking: bool = False

            def quack(self) -> None:
                self.quacking = True
        ```

### For dynamically typed languages

Statically typed languages get a lot of static analysis for free.
In dynamically typed (even interpreted) languages, incorporating 3rd-party tools can be helpful.

Use IDEs like IntelliJ, PyCharm and CLion. These are all by JetBrains, and they’re similar.
They have configurable _inspections_ that can detect potential bugs and bad coding practices.
They can make your coding experience much easier too, via Git integration and refactoring tools.

!!! tip
    You can use [Python’s typing package](https://docs.python.org/3/library/typing.html) to declare
    types, which also improves documentation (in Sphinx autodoc and mkdocs).

Tools in Python include [mypy](https://pypi.org/project/mypy/),
[BugBear](https://pypi.org/project/flake8-bugbear/),
[Safety](https://github.com/pyupio/safety), [Bandit](https://pypi.org/project/bandit/),
and [CodeQL](https://github.com/github/codeql-action).
PyCharm and mypy both perform type checks.
These find cases where a function expects one type of input, and you pass another type.

## Layer 1 - Unit

Unit tests check a single function or class.
They should cover every aspect of the **contract** of a function or class.
**A good unit test doubly serves as documentation** for how to use a class, and its exact behavior.

The contract for a function or class covers:

1. The input it accepts
2. Its output
3. Its side effects
4. Errors it raises and under which conditions

### (i) Input

First, the input is part of the contract. This includes the **types and meanings of parameters**,
and **invariants that must hold** (ex a matrix is invertible, or the input lengths should match).
In most modern understandings of software development, a **function should balk on invalid input**
because the contract is not fulfilled, and as part of its own contract (to throw errors).

### (ii) Output

The output is part of the contract. This covers the type of output and the meanings with
respect to the inputs. Edge cases are crucial in this. Good edge cases include empty arrays,
null values, 0, negative numbers, infinite values, NaN, incorrect types, invalid paths,
and strings containing control characters. Also test numbers likely to underflow (1E-300)
and overflow (1E300).
Your unit test documents this contract by including these edge cases.

### (iii) Side effects

The side effects. This includes files written to or modified. Equally importantly,
it includes any **modification to the object’s state or the state of an input**.
If your function is supposed to return a copy, check that it does not modify the original’s state.
Using completely immutable objects can save some pain here and reduce difficult‐to‐find bugs,
especially for concurrent code. It also has some formal advantages and works great with functional
programming.

### (iv) Errors

Behavior under failure. Your function should declare the errors (exceptions) it raises
and the conditions under which they are raised. This is easy in JUnit, scalatest, and pytest.
(For example, using `with pytest.raises(ValueError):`.)

### Mocking

[Mocking](https://stackoverflow.com/questions/2665812/what-is-mocking) is a crucial part of
writing unit tests.

However, it is often better to focus on writing units (classes and functions)
that are modular enough that you don’t even need to mock an object: Your function
simply doesn’t use any others. Keep your classes separated from each other as possible.

Focusing on ease of testing immediately – or even before writing code – can improve
your code’s **modularity and thereby clarity, maintainability, and testability**.
It can be harder in some situations, such as in database‐connected code.
Try to keep your database separate from the code that doesn’t strictly need it.
[Don’t couple](https://en.wikipedia.org/wiki/Loose_coupling)
and [Don’t talk to strangers.](https://en.wikipedia.org/wiki/Law_of_Demeter)

### Property tests

**Property tests** are uncommon but powerful tests.
[QuickCheck](https://hackage.haskell.org/package/QuickCheck) is the quintessential example,
but there’s also [ScalaCheck](https://www.scalacheck.org/) in Scala and
[Hypothesis](https://hypothesis.readthedocs.io) in Python.

These use _strategies_ to define what constitutes valid input and automatically generates
conforming data. Predefined strategies for things like strings, numbers, and lists are
provided. Obvious edge cases are always tested for these strategies, such as 0, empty lists,
and control characters.

Invariants are then tested on generated data. An especially useful case is if you have a function
and its inverse. For example, a QR code reader `r` and a QR code writer `w`.
Then `r(w(s))` and `w(r(s))` should hold for any string `s`.
In Hypothesis, the first can be written as

```python
from hypothesis import given
from hypothesis import strategies


@given(strategies.text())
def test(qr_text: str) -> None:
    assert decode(encode(qr_text))
```

Then if it fails for an empty string:

```
> Falsifying example: test(qr_text='')
```

**These can be very powerful tests** that catch bugs that are otherwise difficult to detect.
For example, I found a bug affecting only quad‐width Unicode characters
(in code that never referenced character information.)

## Layer 2 - Integration

Integration tests use multiple classes or functions and make sure that your high‐level
code uses them correctly in concert.
You should know the expected output beforehand, and the tests should run under automation.
While they can’t reasonably test everything in most cases, they should check the _full output_
for specific, known cases. Include tests on edge‐case inputs.

!!! note
    You can use property tests in integration tests, too.

### Concurrency

Concurrent code should be tested under concurrent conditions.
Use known testing patterns to probe for [deadlocks](https://en.wikipedia.org/wiki/Deadlock)
and [race conditions](https://en.wikipedia.org/wiki/Race_condition).

### Image comparisons

Your plotting code should mostly be tested without using an actual plotting backend.
Doing this also lends to more modular code.
However, checking the plotting output directly is valuable, perhaps once for each function.
Often this can be a manual sanity check, comparing the images by eye.
You can also add an image in a regression test, but you’ll need to modify it if you make a
stylistic change. If you use a manual check, put it alongside the code for reference.

### Timezones and locales

Where applicable, check your timezone computations.
Not handling timezones correctly can introduce errors for users outside your region.

## Layer 3 - System

### End-to-end tests

TODO

### Sanity checks

These test your code on simple cases.
These are a useful layer of testing because they’re easy to write.
They don’t test correctness in more general cases, and they’re weak to results that are just _slightly_ wrong.

### Regression tests

Regression tests make sure your output doesn’t change as you change your code.
You don’t necessarily know the correct answer for these.
They’re incomplete, and it’s easy to believe output looks correct after you’ve seen it.
(Instead, always write the expected output before seeing the actual output.)
But they’re useful for catching obvious failures immediately.

## Layer 4 - Acceptance

This layer checks that the software you wrote actually satisfies design requirements.

- Is it easy to use?
- Is it documented?
- Is it fast enough?
- Does it work in the needed natural languages?

### Load and stress

Load and stress types are two types of performance tests.
They’re actually different: Software should pass a load test can’t exactly _pass_ a stress test.
Typically, the load is increased until the system fails, and the test makes sure the system
handles the failure well. For example, without losing data or catching fire.

### Security

TODO

### Fault injection

TODO

### Localization

!!! tip
    Make sure your code uses YY-mm-dd formats and only uses Unicode strings.

### Accessibility

TODO

### Usability

TODO

## Automation and DevOps

Now for making testing easier.

### Test runners

Your tests should run on a single command.
[ScalaTest](https://www.scalatest.org/), [Pytest](https://docs.pytest.org/en/stable/),
and [JUnit 5](https://junit.org/junit5/) are good choices.
In Python, also consider something like [tox](https://tox.readthedocs.io/).

### Coverage analysis

Coverage is a simple indicator of how much of your code is tested.

Coverage analyzers test either static coverage by examining calls in the tests,
or runtime coverage by analyzing the code branches that are actually executed by your tests.
The Python package [coverage](https://coverage.readthedocs.io) analyzes runtime coverage and can give a report of
percent coverage and the specific execution branches (and lines of code) that were not covered.

These do not assess what edge cases were tested or other important metrics.
So a low coverage is alarming, but a high coverage is only part of the need.

### Mutation testing

In contrast to fuzzing, mutation testing randomly mutates your _code_.
The idea is that if your tests still pass on the mutated code,
the tests probably were inadequate. It works well with coverage analyzers.
It’s very uncommon.

### Code quality analyzers

These are tools that broadly estimate code quality.
[Code Climate](https://codeclimate.com/) is one example.
These tools are useful but not very intelligent.
[sloccount](https://dwheeler.com/sloccount/) or [pygount](https://pypi.org/project/pygount/)
can be useful too. Good code is usually on the shorter side.

## Table of test types

This is a collection of various types of tests.

| test type       | when it passes                                     | type       | layers | general |
|-----------------|----------------------------------------------------|------------|--------|---------|
| unit            | Components behave correctly, esp. for edge cases   | functional | 1      | yes     |
| integration     | 2 or more components behave correctly in concert   | functional | 2      | yes     |
| property        | Invariants hold for generated data                 | functional | 1–3    | yes     |
| assertion       | Internal state makes sense (during runtime)        | functional | 1–3    | no      |
| system          | All components behave correctly together           | functional | 3      | yes     |
| concurrency     | The system works in multi‐threaded environments    | functional | 3      | yes     |
| regression      | Results match the previous run’s                   | functional | 3      | no      |
| end-to-end      | Sequence of user actions gives valid results       | functional | 3      | no      |
| smoke           | The software runs without failure on correct input | functional | 3      | no      |
| sanity          | Output makes some sense                            | functional | 3      | no      |
| fault injection | Injecting faulty data causes a good failure mode   | functional | 3      | no      |
| mutation        | Injecting errors in code causes the tests to fail  | functional | -      | -       |
| load            | The system handles a large load                    | acceptance | 4      | no      |
| stress          | The system fails gracefully                        | acceptance | 4      | no      |
| security        | The software is difficult to exploit               | acceptance | 4      | no      |
| usability       | The software is easy to use                        | acceptance | 4      | no      |
| localization    | Locale-specific behavior is correct                | acceptance | 4      | no      |
| compatibility   | Behavior is correct under required OSes, etc.      | acceptance | 4      | no      |
| performance     | Code runs sufficiently quickly                     | acceptance | 4      | no      |
