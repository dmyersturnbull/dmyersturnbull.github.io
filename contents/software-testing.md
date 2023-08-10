# Software testing

This article is meant as an introduction to software testing for scientific software.

## Let’s get this out of the way – you must write tests.

Tests are just as required in scientific software as in all other software.
_If you’re already convinced, skip this section._

“Researchers are spending more and more time writing computer software to model biological
structures, simulate the early evolution of the Universe and analyse past climate data, among
other topics.
But **programming experts have little faith that most scientists are up to the task.**”
― [Merali 2010 (doi:10.1038/467775a)](https://pubmed.ncbi.nlm.nih.gov/20944712/) (bolding changed)

Here’s what happens:
[5 retractions in one lab due to a bug](https://science.sciencemag.org/content/314/5807/1856).
Yet because code is often not released and few others would bother to try to reproduce published
results, probably 90%+ of scientific software bugs remain uncaught.
A lack of deceptive intent doesn’t lessen the damage, and not testing is reckless.
**Not testing your software is as egregious a fault in scientific integrity as p‐hacking.**

On a software development team, you can’t push new code to a main branch without accompanying
tests – which must pass.
In fact, many good coders [write tests first](https://en.wikipedia.org/wiki/Test-driven_development),
before any other code.

Professional software developers are the world’s best coders, so the code they write presumably
has the lowest per‐line error rate.
Yet no decent programmer would trust themselves to write code that works without tests.
So why do scientists routinely write, use, and even publish on the basis of code without tests,
_code that is almost certainly faulty_?
Let’s not do that. You must write tests.

If you’re still not convinced, **let’s try a thought experiment.**
Count the number of times you’ve done this:

1. You run your code. It _raises an error_ or gives an unreasonable result.
2. You trace through to find the error and _fix the bug_.
3. Now your _code doesn’t error_ and _gives a resasonable result._

Each bug could _just as easily_ have not caused an error.
**This process does not make your code correct; it just selects for results that look reasonable.**

## Types of tests

Lots of types of tests: unit, validation, integration, property, load, stress,
fuzz, regression. Let’s simplify the landscape.

Some literature distinguishes between validation & verification.
These terms are confusing and have disputed meanings.
Let’s forget about them. A more useful distinction is between
[functional](https://en.wikipedia.org/wiki/Functional_testing)
and [non‐functional](https://en.wikipedia.org/wiki/Non-functional_testing) tests.
But let’s forget those too.

Let’s instead use a distinction especially relevant to the way scientists often test software:
_tests that can be used to show correctness in a general sense (**Class GENERAL**)_,
and _tests that cannot (**Class CHECK**)_. This is my own language, but I think it’s useful.
Here we are, the 5 _classes_ of tests:

| Class   | What is tested                         | Example types of tests                |
| ------- | -------------------------------------- | ------------------------------------- |
| GENERAL | correctness in the general case        | unit, integration, & property †       |
| CHECK   | limited subsets of code behavior       | smoke, sanity, regression             |
| PATHO   | behavior under pathological conditions | load, stress, fault injection         |
| SUPPOR  | general‐case correctness, supportive   | type checking, assertion, & fuzzing ‡ |
| ACCEPT  | software quality or usefulness         | acceptance, internationalization      |

† The first category (Class GENERAL) _can_ be used to test general‐case correctness,
but some might only test specific aspects of behavior.

‡ See [testing under duck typing](#-testing-under-duck-typing) for why type checking
can constrain the input surface and enable complete test suites. This makes them crucial
in testing general‐case correctness.

There’s a more complete but perhaps exhausting picture at the end of this article.
It doesn’t matter much where you draw the distinction between these types.
Where does a unit test end and an integration test begin? It doesn’t matter as long
as you distinguish between the extremes and have both.

## Layers you should have

The next few sections cover layers of testing from highest (3) to lowest (0).
**Your code should be covered with Layers 0 to 3** at least.

| Layer              | What it is                                    | Class   |
| ------------------ | --------------------------------------------- | ------- |
| 0                  | static analysis                               | SUPPORT |
| 1                  | unit and property tests                       | GENERAL |
| 2                  | integration tests                             | GENERAL |
| 3                  | real‐data, regression, & sanity tests         | CHECK   |
| Pathological-state | fuzzing, fault injection, load, & stress      | PATHO   |
| Acceptance         | i18n, documentation, performance, & usability | ACCEPT  |

--

## Layer 3: Real‐data, regression, and sanity tests (Class CHECK)

These are already common in scientific software.

### Sanity checks:

_Scientists are excellent at sanity checking_.
These test your code on simple cases (like a 1-by-1 matrix).
These are a crucial layer of testing because they’re easy to write
and can catch some errors that cause extremely wrong results.
More importantly, they don’t test correctness in more general cases, and they’re weak to
results that are just _slightly_ wrong.
A publication with a slightly wrong result is a publication with a false result. Not ideal.

### Tests on real data:

These are crucial for catching results that are very wrong early.
But real data is too complex to know the correct output, and these tests are incomplete.
Include them as an important layer.

### Regression tests:

Regression tests make sure your output doesn’t change as you change your code.
You don’t necessarily know the correct answer for these.
They’re incomplete, and it’s easy to believe output looks correct after you’ve seen it.
(Instead, always write the expected output before seeing the actual output.)
But they’re useful for catching obvious failures immediately.

### Image comparisons:

Your plotting code should mostly be tested without using an actual plotting backend.
Doing this also lends to more modular code.
However, checking the plotting output directly is valuable, perhaps once for each function.
Often this can be a manual sanity check, comparing the images by eye.
You can also add an image in a regression test, but you’ll need to modify it if you make a
stylistic change. If you use a manual check, put it alongside the code for reference.

## Layer 2: Integration tests (GENERAL class)

Integration tests use multiple classes or functions and make sure that your high‐level
code uses them correctly in concert.
You should know the expected output beforehand, and the tests should run under automation.

While they can’t reasonably test everything in most cases, they should check the _full output_
for specific, known cases. Include tests on edge‐case inputs.

## Layer 1: Unit tests and property tests (GENERAL class)

Unit tests check a single function or class.
They should cover every aspect of the **contract** of a function or class.
**A good unit test doubly serves as documentation** for how to use a class, and its exact behavior.

The contract for a function or class covers:

1. The input it accepts
2. Its output
3. Its side effects
4. Errors it raises and under which conditions

### 1. Input:

First, the input is part of the contract. This includes the **types and meanings of parameters**,
and **invariants that must hold** (ex a matrix is invertible, or the input lengths should match).
In most modern understandings of software development, a **function should balk on invalid input**
because the contract is not fulfilled, and as part of its own contract (to throw errors).

### 2. Output:

The output is part of the contract. This covers the type of output and the meanings with
respect to the inputs. Edge cases are crucial in this. Good edge cases include empty arrays,
null values, 0, negative numbers, infinite values, NaN, incorrect types, invalid paths,
and strings containing control characters. Also test numbers likely to underflow (1E-300)
and overflow (1E300).
Your unit test documents this contract by including these edge cases.

### 1. Side effects:

The side effects. This includes files written to or modified. Equally importantly,
it includes any **modification to the object’s state or the state of an input**.
If your function is supposed to return a copy, check that it does not modify the original’s state.
Using completely immutable objects can save some pain here and reduce difficult‐to‐find bugs,
especially for concurrent code. It also has some formal advantages and works great with functional
programming.

### 1. Errors:

Behavior under failure. Your function should declare the errors (exceptions) it raises
and the conditions under which they are raised. This is easy in JUnit, scalatest, and pytest.
(For example, using `with pytest.raises(ValueError):`.)

### Mocking when needed

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

### Property tests:

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
def test(qr_text: str):
    assert decode(encode(qr_text))
```

Then if it fails for an empty string:

```
> Falsifying example: test(qr_text='')
```

**These can be very powerful tests** that catch bugs that are otherwise difficult to detect.
For example, I found a bug affecting only quad‐width Unicode characters
(in code that never referenced character information.)

## Layer 0: Type checking and static analysis (SUPPORT class)

Static analysis is a freebie.
There are lots of tools you can easily add to your test infrastructure to detect potential bugs.

IDEs like IntelliJ, [PyCharm](https://www.jetbrains.com/pycharm/), and CLion can catch simple bugs
in Java, Scala, Python, and C/C++. These are all by JetBrains, and they’re similar.
They have configurable _inspections_ that can detect potential bugs and bad coding practices.
They can make your coding experience much easier too with Git integration and refactoring tools.
For example, you can rename a function and update all references to it. Or move a file.

Tools in Python include [mypy](https://pypi.org/project/mypy/),
[BugBear](https://pypi.org/project/flake8-bugbear/),
[Safety](https://github.com/pyupio/safety), [Bandit](https://pypi.org/project/bandit/),
and [CodeQL](https://github.com/github/codeql-action).
PyCharm and mypy both perform type checks.
These find cases where a function expects one type of input and you pass another type.
You can use [Python’s typing package](https://docs.python.org/3/library/typing.html) to declare
types, which also improves documentation (Sphinx autodoc can include this when generating docs).

These are also a pretty good idea to **limit the testing surface** you need. Below explains why.

### [#](#-testing-under-duck-typing) Testing under duck typing

Type checking cannot be used directly to show correctness, but it can close off the expected
input in a way that makes a complete test suite possible.
In untyped languages (ex Python), you might write a function that expects a "matrix".
Then, you write a test suite for the function. Later, someone else uses your API
but calls your function on a matrix defined in a different package, maybe with the "\*" operator
defined element‐wise instead of as matrix multiplication. Your code then returns a valid but
incorrect result. Your user could not have anticipated this, you were correctly following Pythonic
duck typing, and the output was wrong (and maybe ended up in a paper).
This is a massive problem with that paradigm.

## Pathological‐state layer (PATHO class)

These layers should be covered in cases where they are relevant.

### Timezone and locale

These matter less in some scientific software, but **check your timezone computations**.
Not handling timezones correctly can introduce serious problems for users outside of your region.

Unrelated to testing, make sure your code uses YY-mm-dd formats and only uses Unicode strings.
Keep your code compatibile with other operating systems if it’s easy enough.
Use `System.os.sep` in Java and `pathlib` in Python rather than assuming `/`.

### Fuzzing and fault injection

[Fuzzing](https://en.wikipedia.org/wiki/Fuzzing) and
[fault injection](https://en.wikipedia.org/wiki/Fault_injection) are useful in many cases.
An example fuzz test is passing an object with behavior that does not conform to the contract
but is likely to pass the function’s assertion checks.
An example fault injection is modifying bytes in memory during execution.

### Concurrency

Concurrent code should be tested under concurrent conditions.
Use known testing patterns to probe for [deadlocks](https://en.wikipedia.org/wiki/Deadlock)
and [race conditions](https://en.wikipedia.org/wiki/Race_condition).

### Load and stress

Load and stress types are two types of performance tests.
They’re quite different: Software should pass a load test can’t exactly _pass_ a stress test.
Typically, the load is increased until the system fails, and the test makes sure the system
handles the failure well. For example, without losing data or catching fire.

## Acceptance layer (ACCEPT class)

This layer checks that the software you wrote actually satisifies the real‐world requirements.

- Is it easy to use?
- Is it documented?
- Is it fast enough?
- Does it work in the needed natural languages?

### Automation and DevOps

Now for making testing easier.

### Test runners

Your tests should run on a single command.
[ScalaTest](https://www.scalatest.org/), [Pytest](https://docs.pytest.org/en/stable/),
and [JUnit 5](https://junit.org/junit5/) are good choices.
In Python, also consider something like [tox](https://tox.readthedocs.io/).

### Coverage analysis

Coverage is a simple indicator of how much of your code is tested.

Coverage analyzers test either static coverage by
examining calls in the tests, or runtime coverage by analyzing the code branches that are
actually executed by your tests. The Python package [coverage](https://coverage.readthedocs.io)
analyzes runtime coverage and can give a report of percent coverage and the specific execution
branches (and lines of code) that were not covered.

These do not assess what edge cases were tested or other important metrics.
So a low coverage is alarming, but a high coverage is only part of the need.

### Mutation testing

In contrast to fuzzing, mutation testing randomly mutates your _code_.
The idea is that if your tests still pass on the mutated code,
the tests probably weren’t adequate. They work well with coverage analyzers.
It’s pretty uncommon.

### Code quality analyzers

These are tools that broadly estimate code quality.
[Code Climate](https://codeclimate.com/) is one example.
These tools are useful but not very intelligent.
[sloccount](https://dwheeler.com/sloccount/) or [pygount](https://pypi.org/project/pygount/)
can be useful too. Good code is usually on the shorter side.

### Python‐specific DevOps

More on this in another article.
For now see [the Python build landscape](#-the-python-build-landscape)
and [Tyrannosaurus](https://github.com/dmyersturnbull/tyrannosaurus).

## Supplemental table

This is a collection of various types of tests.

| test type        | when it passes                                             | correctness |
| ---------------- | ---------------------------------------------------------- | ----------- |
| load             | The system handles a large load                            | no          |
| stress           | The system fails gracefully                                | no          |
| unit             | A function or class behaves correctly, esp. for edge cases | yes         |
| integration      | Functions and classes behave correctly in concert          | yes         |
| property         | Invariants hold for generated data                         | yes         |
| fuzzing          | Injecting faulty data causes a good failure mode           | yes         |
| mutation         | Injecting errors in code causes the tests to fail          | yes         |
| concurrency      | The system works in multi‐threaded environments            | yes and no  |
| smoke            | The software runs without failure on correct input.        | no          |
| sanity           | Results make sense, esp. by manual inspection              | no          |
| assertion        | Sanity checks that run as part of the software             | no          |
| type checking    | Static checking of types, as in compiled languages         | no ‡        |
| real‐world data  | Tests that a result makes sense using real data            | no          |
| regression       | Results stay constant as development continues             | no          |
| acceptance       | The software satisfies deliverable conditions.             | no          |
| localization     | Required languages are covered and behavior is correct.    | mostly no   |
| compatibility    | Behavior is correct under required operating systems, etc. | mostly no   |
| time constraints | Code runs sufficiently quickly.                            | no          |
