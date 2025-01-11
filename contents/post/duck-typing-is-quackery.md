# Duck typing is quackery

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

_Apologies for the pun, and to [Phil Haack](https://haacked.com/archive/2014/01/04/duck-typing/), who beat me to it._

## What is duck typing?

Duck typing is a dynamic type system, popularized by Python and Ruby, that applies the
[duck test](https://en.wikipedia.org/wiki/Duck_test):

> If it looks like a duck, swims like a duck, and quacks like a duck, then it is probably a duck.

In programming, the duck test becomes:

> If it has no-arg functions `swim` and `quack`, then it is probably a duck.

The claimed benefits are (a) not having to worry about types, and (b) decreased coupling because interfaces are implied.
But the downsides are substantial.
I want to focus on two downsides that seem seldom discussed.

1. Listing types provide structured, easy-to-glean documentation,
   a practice that duck typing countermands.
2. Because users can pass instances of any types, tests must cover arbitrary inputs.

I’ll discuss these through a real example.

## A matrix algorithm

You devised some clever matrix algorithm that operates on two matrices and outputs a third.
After putting your paper on arXiv, you implement it in three languages—Java, Scala, and Python.

=== "Java"

    ```java
    import org.nd4j.linalg.api.ndarray.IndArray;
    public class MyAlgorithm {
        public Matrix calculate(IndArray matrixA, IndArray matrixB) {
            // some fancy things...
            return finalMatrix;
        }
    }
    ```

=== "Scala"

    ```scala
    import breeze.linalg.Matrix;
    class MyAlgorithm {
      def calculate(matrixA: Matrix, matrixB: Matrix): Matrix = {
        // some fancy things...
        finalMatrix
      }
    ```

=== "Python"

    ```python
    class MyAlgorithm:
        def calculate(self, matrix_a, matrix_b):
            # some fancy things...
            return final_matrix
    ```

In Java, the method takes two `IndArray` instances and outputs a third.
If people read your paper, it’s clear how to use it.
In Scala, the function takes two [Breeze Matrices](http://www.scalanlp.org/api/breeze/#breeze.linalg.Matrix)
and outputs a matrix.

For the Python code, you realize that `matrix_a` isn’t clear to users.
You don’t want them passing in lists of lists, so you add some documentation:

```python
class MyAlgorithm:
    def calculate(self, matrix_a, matrix_b):
        """
        Calculates on matrices a and b.

        Arguments:
            matrix_a: A matrix, like Numpy’s (i.e., not a list of lists)
            matrix_b: A second matrix

        Returns:
            A matrix
        """
        # some fancy things...
```

That looks Pythonic.
[Better to ask for forgiveness than permission.](https://stackoverflow.com/questions/12265451/ask-forgiveness-not-permission-explain)

Then, you write some tests.
In fact, you test your code with Numpy `ndarray`,
[PySpark matrices](https://spark.apache.org/docs/latest/api/python/reference/api/pyspark.mllib.linalg.Matrices.html),
and [Polars DataFrames](https://pola-rs.github.io/polars/py-polars/html/reference/dataframe/index.html).
That’s three times the work of your Java and Scala implementations, but at least you’re safe and sound.

A year later, a PhD student in a dark room finds your lovely Python library.
It’s got 450 GitHub stars, so it must be good.
She incorporates it into her own code, which she’s already written tests for.
She’s not testing your code—nor should she. She assumes it works.
She gets an answer—a reasonable-looking matrix, and it gets published.
Of course, it’s wrong.

What happened?
Somewhere in `calculate` is this code:

```python
def calculate(self, matrix_a, matrix_b):
    # some fancy things
    final_matrix = matrix_a_prime * matrix_b_prime
    return final_matrix
```

You assumed element-wise multiplication because thats what [Numpy `ndarray`](https://numpy.org/doc/stable/reference/generated/numpy.ndarray.html) does.
The matrix library she used defines `__mul__` as matrix multiplication.
That’s not her fault.
Maybe you can improve the documentation:

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

Ok, it got out of hand.
We’ve made a lot of work for ourselves writing docs and tests,
made an unreadable mess of documentation,
and still failed to over all possible libraries that follow the documented semantics.
But it really wasn’t your fault; you were writing Pythonic code and following duck typing.

In contrast, our Scala code was easy to test, and it’s easy to understand how to use at a glance.

```scala
import breeze.linalg.Matrix;
class MyAlgorithm {
  def calculate(matrixA: Matrix, matrixB: Matrix): Matrix = {
    // some fancy things...
    matrixAPrime * matrixBPrime
  }
}
```

When documentation is rendered, it shows that `matrixA` and `matrixB` are both `breeze.linalg.Matrix`.
Upon seeing the method signature, a user could read up about how Breeze matrices works.
Alternatively, they could skip that --
because you, as the library author, are certifying that your code works with Breeze matrices.
If they’re using matrices of another library, they can write an adapter.

```scala
import breeze.linalg.Matrix;

class GooborToBreezeMatrixAdapter extends Matrix {
  def *(other: GooborMatrix): GooborMatrix = this.matrixMultiply(other)
}
```

??? note "Note – Scala structural typing"

    Scala supports true compile-time structural typing.
    You could easily rewrite `calculate` like this:

    ```scala
    type Matrix = {
      def rows: Int
      def cols: Int
      def +(other: Matrix): Matrix
      def *(other: Matrix): Matrix
    }
    class MyAlgorithm {
      def calculate(matrixA: Matrix, matrixB: Matrix): Matrix = {
        // some fancy things...
        matrixAPrime * matrixBPrime
      }
    }
    ```
    This can be useful, but perhaps not here (because `*` is ambiguous).

## Example 2: Lets break `quack`

Let’s consider a much simpler example.
A `quack` function could behave in _at least_ two ways:

=== "Stateful duck"

    ```python
    from dataclasses import dataclass


    @dataclass()
    class Duck:
        name: str
        quacking: bool = False

        def quack(self) -> None:
            self.quacking = True  # (1)!
    ```

    1. Make _this_ duck quack.

=== "Stateless duck"

    ```python
    from dataclasses import dataclass
    from typing import Self


    @dataclass(frozen=True, slots=True)
    class Duck:
        name: str
        quacking: bool = False

        def quack(self) -> Self:
            return Duck(quacking=True)  # (1)!
    ```

    1. Return a new duck that’s quacking.

When using this function, how do you call it?
You have two options.

=== "Stateful duck"

    ```python
    def do_something_with_ducks(duck):
        duck.quack()
        ...
    ```

=== "Stateless duck"

    ```python
    def do_something_with_ducks(duck):
        duck = duck.quack()
        ...
    ```

In fact, what really matters is the _behavior_ of the duck, not whether it’s a duck.
Knowing (or suspecting) that it’s a duck is not enough; you need to know how the duck-like object behaves.
As Alex Martelli (the author of Python in a Nutshell) wrote in an email thread:

!!! quote

    Amen, hallelujah. You don’t really care for IS-A -- you really only care for BEHAVES-LIKE-A- [...],
    so, if you do test, this behaviour is what you should be testing for
    **--- [Alex Martelli](https://groups.google.com/g/comp.lang.python/c/CCs2oJdyuzc/m/NYjla5HKMOIJ)**
