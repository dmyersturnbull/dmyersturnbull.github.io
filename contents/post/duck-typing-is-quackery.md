# Duck typing is quackery

!!! warning
    This document is a draft.

## Arbitrarily large input spaces

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

## A `quack` function

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

Code that calls `quack()` really does need to know which of these two
