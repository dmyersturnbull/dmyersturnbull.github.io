# Java conventions

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

Refer to [Google’s Java style guide](https://google.github.io/styleguide/javaguide.html)
for additional recommendations.

## Banned features

These features are **totally** banned:

- `clone()` and `Cloneable`
- `finalize()`
- `System.gc()`
- labels (e.g. `outer_loop: for ...`)
- `notify()` and `wait()`

These features are **partly** banned:

- non-`final` or mutable `static` fields
- Arrays (use collections instead)

### Collections and arrays

Prefer collections to arrays unless doing so causes significant performance issues.

## Comments

Forgo comments or Javadoc elements that are superfluous or included out of habit or convention.
Remove any text that is obvious, repetitious, unclear, or wrong.

<b>Examples of good and bad comments:</b>

- ✅ `@return Result; -1 if {@code list} is empty` (**edge case**)
- ✅ `// skip sort because gatorx sorts incidentally` (**not a mistake**)
- ✅ `// yes, we really do want to add 1 here` (**not a mistake**)
- ✅ `// This block is a bit tricky: ...` (**explain difficult code**)
- 🟨 `// == Algorithm start ==` (**usually better to split the method**)
- ❌ `@return A String` (**only out of habit/convention**)
- ❌ `// set x equal to 5` (**obvious**)
- ❌ `created by Kerri Johnson` (**superfluous to Git**)
- ❌ `created on 2022-10-27` (**superfluous to Git**)

## Exceptions

Both checked and unchecked exceptions are fine.
Avoid throwing general types like `RuntimeException`.

## Constructors

As a general guideline, constructors should map arguments transparently to fields.
If more complex functionality needs to happen to construct the object,
move it to a factory, builder, or static factory method.

## Optional types

!!! rationale

    Although the Java developers may not have originally intended such widespread usage,
    it makes code **much** more clear and much more robust.

Don’t return `null` or accept `null` as an argument in public methods; use `Optional<>` instead.
`null` is permitted in non-public code to improve performance.

## Immutability and records

Prefer immutable types, and use records for data-carrier-like classes.
In general:
Immutable classes must have only `final` fields and should not allow modification (except by reflection);
constructors should make defensive copies, and getters should return defensive copies or views.
This may not always be the appropriate choice, such as in places where performance is paramount.

## Getters, setters, and builder methods

Use `getXx()`/`setXx()` for mutable types but `Xx()` for immutable types:

- For _mutable_ types: name the getter `public double getAngle()` (_get-style naming_)
- For _immutable_ types: name the getter `public double angle()` (_record-style naming_)

Builder methods should follow the immutable convention (i.e. `angle()`).

### Overriding `toString`

!!! tip

    IntelliJ can do this for you.
    Use the `StringJoiner` `toString` template.

Classes should typically override `toString` and use this template:

```java
public class Claz {

    private final String name;
    private final List<String> items;

    public Test(String name, List<String> items) {
        this.name = name;
        this.items = new ArrayList<>(items);
    }

    @Override
    public String toString() {
        return new StringJoiner(", ", Test.class.getSimpleName() + '[', "]")
            .add("name='" + name + '\'')
            .add("items=" + items)
            .toString();
    }
}
```

## Overriding `compareTo`

Immutable classes should implement `Comparable` and override `compareTo` as long as it is reasonable.
`compareTo` should be marked `final`.

## Overriding `hashCode`

!!! tip

    IntelliJ can do this for you.
    Use the default `hashCode` template.

Most classes should override `hashCode` and `equals`.
`hashCode` should use this template:

```java
public class Claz {
    @Override
    public int hashCode() {
        return Objects.hash(field1, field2); // ...
    }
}
```

## Overriding `equals`

!!! tip

    IntelliJ can do this for you.
    Use the provided `hashCode` and `equals` templates.

`equals()` may use either

- _universal equality_, where `equals()` returns `false` for incompatible types
- _multiversal equality_, where `equals()` throws an exception for incompatible types

<small>
In some languages, type safety of equality can be checked by the compiler.
[Scala 3 has type-safe multiversal equality](https://docs.scala-lang.org/scala3/book/ca-multiversal-equality.html).
</small>

Use `getClass()` to check type compatibility, **not** `instanceof`.
(For universal equality, only `getClass()` makes sense – and for multiversal equality, there is no difference.)
Additionally, subclasses of classes defining `equals()` should never add data or state.

### Universal equality

For universal equality, use this template:

```java
public class Claz {

  private final String name;
  private final List<String> items;

  @Override
  public int hashCode() {
    return Objects.hash(name, items);
  }

  @Override
  public boolean equals(final Object obj) {
    if (obj == this) {
      return true;
    }
    if (obj == null || getClass() != obj.getClass()) {
      return false;
    }
    final var o = (Claz) obj;
    return Objects.equals(name, o.name) && Objects.equals(items, o.items);
  }
}
```

??? tip "IntelliJ template for universal equality"

    Use this IntellJ template.
    Under Generate ➤ equals() and hashCode() ➤ ...
    make a new template called _universal_.

    <b>`equals()` template:</b>

    ```text
    #parse("equalsHelper.vm")
    @Override
    public boolean equals(final Object obj) {
    if (obj == this) {
    return true;
    }
    if (obj == null || getClass() != obj.getClass()) {
    return false;
    }
    final var o = (${class.getName()}) obj;
    return ##
    #set($i = 0)
    #foreach($field in $fields)
    #if ($i > 0)
    && ##
    #end
    #set($i = $i + 1)
    #if ($field.primitive)
    #if ($field.double || $field.float)
    #addDoubleFieldComparisonConditionDirect($field) ##
    #else
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #end
    #elseif ($field.enum)
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #elseif ($field.array)
    java.util.Arrays.equals($field.accessor, obj.$field.accessor)##
    #else
    java.util.Objects.equals($field.accessor, obj.$field.accessor)##
    #end
    #end
    ;
    }
    ```

    <b>`hashCode()` template:</b>

    ```
    public int hashCode() {
    #if (!$superHasHashCode && $fields.size()==1 && $fields[0].array)
    return java.util.Arrays.hashCode($fields[0].accessor);
    #else
    #set($hasArrays = false)
    #set($hasNoArrays = false)
    #foreach($field in $fields)
    #if ($field.array)
    #set($hasArrays = true)
    #else
    #set($hasNoArrays = true)
    #end
    #end
    #if (!$hasArrays)
    return java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    );
    #else
    #set($resultName = $helper.getUniqueLocalVarName("result", $fields, $settings))
    #set($resultAssigned = false)
    #set($resultDeclarationCompleted = false)
    int $resultName ##
    #if($hasNoArrays)
    = java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if(!$field.array)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    #end
    );
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #elseif($superHasHashCode)
    = super.hashCode(); ##
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #foreach($field in $fields)
    #if($field.array)
    #if ($resultDeclarationCompleted)
    $resultName ##
    #end
    = ##
    #if ($resultAssigned)
    31 * $resultName + ##
    #end
    java.util.Arrays.hashCode($field.accessor);
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #end
    return $resultName;
    #end
    #end
    }
    ```

### Multiversal equality

For multiversal equality, use this template:

```java
public class Claz {

    private final String name;
    private final List<String> items;

    @Override
    public final int hashCode() {
        return Objects.hash(field1); // ...
    }
    @Override
    public final boolean equals(final Object obj) {
        if (o == this) {
            return true;
        }
        if (o == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            throw new IllegalArgumentException(
                "Type " + obj.getClass().getName()
                  + " is incompatible with "
                  + getClass().getName()
            );
        }
        final var o = (Claz) obj;
        return Objects.equals(name, o.name) && Objects.equals(items, o.items);
    }
}
```

??? tip "IntelliJ template for multiversal equality"

    Use this IntellJ template.
    Under Generate ➤ equals() and hashCode() ➤ ...
    make a new template called _universal_.

    <b>`equals()` template:</b>

    ```text
    #parse("equalsHelper.vm")
    @Override
    public final boolean equals(final Object obj) {
    if (obj == this) {
    return true;
    }
    if (null == obj) {
    return false;
    }
    if (getClass() != obj.getClass()) {
    throw new IllegalArgumentException(
    "Type "
    + obj.getClass().getName()
    + " is incompatible with "
    + getClass().getName()
    );
    }
    final var o = (${class.getName()}) obj;
    return ##
    #set($i = 0)
    #foreach($field in $fields)
    #if ($i > 0)
    && ##
    #end
    #set($i = $i + 1)
    #if ($field.primitive)
    #if ($field.double || $field.float)
    #addDoubleFieldComparisonConditionDirect($field) ##
    #else
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #end
    #elseif ($field.enum)
    #addPrimitiveFieldComparisonConditionDirect($field) ##
    #elseif ($field.array)
    java.util.Arrays.equals($field.accessor, obj.$field.accessor)##
    #else
    java.util.Objects.equals($field.accessor, obj.$field.accessor)##
    #end
    #end
    ;
    }
    ```

    <b>`hashCode()` template:</b>

    ```
    public int hashCode() {
    #if (!$superHasHashCode && $fields.size()==1 && $fields[0].array)
    return java.util.Arrays.hashCode($fields[0].accessor);
    #else
    #set($hasArrays = false)
    #set($hasNoArrays = false)
    #foreach($field in $fields)
    #if ($field.array)
    #set($hasArrays = true)
    #else
    #set($hasNoArrays = true)
    #end
    #end
    #if (!$hasArrays)
    return java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    );
    #else
    #set($resultName = $helper.getUniqueLocalVarName("result", $fields, $settings))
    #set($resultAssigned = false)
    #set($resultDeclarationCompleted = false)
    int $resultName ##
    #if($hasNoArrays)
    = java.util.Objects.hash(##
    #set($i = 0)
    #if($superHasHashCode)
    super.hashCode() ##
    #set($i = 1)
    #end
    #foreach($field in $fields)
    #if(!$field.array)
    #if ($i > 0)
    , ##
    #end
    $field.accessor ##
    #set($i = $i + 1)
    #end
    #end
    );
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #elseif($superHasHashCode)
    = super.hashCode(); ##
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #foreach($field in $fields)
    #if($field.array)
    #if ($resultDeclarationCompleted)
    $resultName ##
    #end
    = ##
    #if ($resultAssigned)
    31 * $resultName + ##
    #end
    java.util.Arrays.hashCode($field.accessor);
    #set($resultAssigned = true)
    #set($resultDeclarationCompleted = true)
    #end
    #end
    return $resultName;
    #end
    #end
    }
    ```

## Naming

Follow [Google’s Java naming conventions](https://google.github.io/styleguide/javaguide.html#s5-naming).
Notably, treat acronyms as words – for example, `CobolError`, **not** `COBOLError`.
You may alter this practice if needed to maintain consistency with an extant convention;
in particular, for `IO` (e.g. in `IOException`).
Name asynchronous methods (those that return a `CompletableFuture`) with the suffix `Async`;
for example, `calculateAsync()`.

## Member ordering

!!! tip

    IntelliJ can do this for you.
    Import the [IntelliJ formatter settings](intellij-style.xml).
    To set manually, choose the default order and enable “keep getters and setters together”.

Sort members by the following rules.
Note that these rules are similar to most existing conventions, including IntelliJ’s default.
I don’t recommend sorting members retroactively because it can result in large diffs.

??? info "Exact sorting rules"

    1. `static final` field
    2. initializer
    3. field
    4. constructor
    5. `static` method
    6. method
    7. getter/setter
    8. `equals`, `hashCode`, and `toString` (in order)
    9. `enum`, `interface`, `static class`, `class` (in order)

Always pair associated getters and setters (getter first).
Within each of the 10 types, sort by decreasing visibility.
_Optionally:_
Consider subsequently sorting methods so that callers are above callees in a breadth-first manner,
or by another natural ordering.

## Style and formatting

Use [prettier-java](https://github.com/jhipster/prettier-java) with:

- 4 spaces for indentation
- print width of 120

### Optional syntax

In general, omit any syntax elements that are not required.
This includes any that have no effect at runtime, excluding comments and annotations.

This includes:

- Optional grouping parentheses
- Optional qualifiers `this` and `super`
- Same/inner/outer class names when accessing within the same file
- Unnecessary qualifiers, such as `abstract` on interface methods
- Explicit `.toString()`

### Variable declarations

Declare variables when they are needed, not at the start of a block.
Use `var` if the type is either obvious or unimportant.
In `main` methods, use `String... args`.

### The `final` keyword

`final` for variables, method arguments, `catch` arguments, `try` resources, etc., is optional.
If a `final` was already added, don’t remove it without cause.

### Other formatting

#### Encoding

Write non-ASCII characters without escaping, except characters that are likely to confuse readers.

#### Comments

Use `//` for multiline comments instead of `/* */`, unless the comment spans many lines (i.e. more than 20).
Prefer [Markdown Documentation Comments](https://openjdk.org/jeps/467) if available.

#### Literals

Always add `.0` to floats (e.g. `double x = 2.0 * pi`) and prefix with `0.` (e.g. `double x = 0.001`).
Digit grouping with `_` is optional; use it only for amounts or quantities, not identifiers.
