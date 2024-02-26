
# Java conventions

Refer to [Google’s Java style guide](https://google.github.io/styleguide/javaguide.html)
for additional recommendations.

## Practices

### Banned features

These features are banned:

- `clone()` and `Cloneable`
- `finalize()`
- `System.gc()`
- labels (e.g. `outer_loop: for ...`)
- `notify()` and `wait()`
- `synchronized` methods (synchronize on blocks instead)
- non-`final` or mutable `static` fields

### Exceptions

Both checked and unchecked exceptions are fine.
Avoid throwing general types like `RuntimeException`.

### Constructors

As a general guideline, constructors should map arguments transparently to fields.
If more complex functionality needs to happen to construct the object,
move it to a factory, builder, or static factory method.

### Optional types

??? rationale

    Although the Java developers may not have originally intended such widespread usage,
    it makes code **much** more clear and much more robust.

Don’t return `null` or accept `null` as an argument in public methods; use `Optional<>` instead.
`null` is permitted in non-public code to improve performance.

### Collections

Prefer collections to arrays unless doing so causes significant performance issues.

### Immutability and records

Prefer immutable types, and use records for data-carrier-like classes.
In general:
Immutable classes must have only `final` fields and should not allow modification (except by reflection);
constructors should make defensive copies, and getters should return defensive copies or views.
This may not always be the appropriate choice, such as in places where performance is paramount.

### Getters, setters, and builder methods

Use `getXx()`/`setXx()` for mutable types but `Xx()` for immutable types:

- For _mutable_ types: name the getter `public double getAngle()` (_get-style naming_)
- For _immutable_ types: name the getter `public double angle()` (_record-style naming_)

Builder methods should follow the immutable convention (i.e. `angle()`).

### `toString`

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

### `hashCode`

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

### `equals`

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

#### Universal equality

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

#### Multiversal equality

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

### `compareTo`

Immutable classes should implement `Comparable` and override `compareTo` as long as it is reasonable.
`compareTo` should be marked `final`.

### `switch` and pattern matching

End every `case` block with a `return` or `break` (no fall-through).
Handle all cases by adding default case if necessary.

### Final

`final` for variables, method arguments, `catch` arguments, `try` resources, etc., is optional.
However, if `final` is present, don’t remove it without cause.

## Formatting

!!! tip

    IntelliJ can do most of this formatting for you.
    Import the [IntelliJ formatter settings](intellij-style.xml).
	Unfortunately, it has some bugs (as of February 2024).
	Specifically, it ignores some wrapping and chopping rules.

### Indentation

Use 4 spaces for indentation and 4 for continuation (block indentation).

### Blank lines

Add one blank line before each top-level declaration, excluding between fields.
Single blank lines MAY be added in other places for clarity.
Do not use multiple consecutive line breaks.
Avoid including blank lines in method bodies:
If the method is long enough to warrant blank lines, it is probably too long.
Either break the method up or replace the blank line with a comment.

### Horizontal spacing and alignment

Follow
[Google’s horizontal whitespace](https://google.github.io/styleguide/javaguide.html#s4.6.2-horizontal-whitespace)
section, which are generally compatible with the IntelliJ formatter’s default settings.
Do not horizontally align.

### Braces and line breaks

Use the original Java style guidelines:

1. Put opening braces on the same line
2. Keep `else` and `else if` on the same line (i.e. `} else {`).
   Similarly, keep `while` on the same line for do-while loops (i.e. `} while ()`).
3. Start a line for every annotation, enum member, and record parameter.

You may omit braces for simple, short, and single-statement`if`/`else`/`else if`, `for`, and `while` blocks.
Place the body on the same line.

??? example

    ```java
    if (s.isBlank()) throw IllegalArgumentException();
    ```

### Line length and breaks

Limit lines to 120 characters.
Break lines, in order of decreasing importance:

1. before `.` in a call chain
2. before each item in a method parameter list, call argument list, annotation parameter list,
   exceptions being `catch`-ed, and resources in a try-with-resources (_chopping_)

#### 1. Breaking call chains

Either keep a call chain on one line or chop it with one line per call.
Use a separate line for the first call if it is logically similar to following lines.
(E.g. `records\n .map(...)\n .filter(...)`, but `MyClass.getInstance()\n .map(...)\n .filter(...)`.)
Always do this for long call chains.

??? example "Examples"

    === "Option 1"

        ```java
        myStream.filter(v -> v > 1.0).map(Integer::toString).limit(10);
        ```

    === "Option 2"

        ```java
        myStream
            .filter(v -> v > 1.0)
            .map(Integer::toString)
            .map(someInstance.someFancyLongNamedMethod)
            .limit(10);
        ```

#### 2. Chopping lists

Place call arguments, etc.:

1. On the same line as the method name
2. On a single line after the method name, or
3. One line per argument (_chopped_)

Chop when necessary to keep the line length within 120.
You may also chop if it greatly improves clarity.

??? example "Chopping method declarations"

    === "Option 1 – short enough"

        ```java
        public void calculateQuota(String data) {
            //
        }
        ```

    === "Option 2 – one line"

        ```java
        public void calculateQuota(
            String data, int alphaCoefficient, Map<String, Datum> extraFields
        ) {
            //
        }
        ```

    === "Option 3 – multiple lines"

        ```java
        public void calculateQuota(
            String data,
            Optional<Integer> alphaCoefficient,
            Map<String, Datum> extraFields,
            String someOtherLongNamedParameter
        ) {
            //
        }
        ```

#### Type declarations

Always start a new line before `permits` (for sealed interfaces).

??? example "Chopping type declarations"

    === "Option 1 (preferred)"

    ```java
    public sealed interface Animal<
        T extends MotorControl<T>,
        I super AnimalInput<T, I>,
        O extends AnimalOutput<T, O>
    > extends AnimalLike<T, I, O>
        permits Vertebrate, Invertebrate { // always wrap before `permits`
    }
    ```

#### Pattern matching

In patterns (enhanced `switch`), multiple case values can be placed on the same line.
Do this only if the items are short.

??? example

    ```java
    public void x(int q) {
      switch (q) {
        case 1, 2, 3 -> false
        case 4, 5, 6 -> true
        default -> throw new IllegalArgumentException("Unexpected value: " + q);
      }
    }
    ```

### Optional syntax

In general, omit syntax that has no effect at runtime (excluding comments and annotations).

This includes:

- Optional grouping parentheses
- Optional qualifiers `this` and `super`
- Same/inner/outer class names when accessing within the same file
- Unnecessary qualifiers, such as `abstract` on interface methods
- Explicit `.toString()`


### Variable declarations

Declare variables when they are needed, not at the start of a block.
Use `var` if the type is either obvious or unimportant.
You may declare multiple variables per line; e.g. `int var1, var2;`.
In `main` methods, use `String... args`.

### Miscellaneous

#### Comments

Use `//` for multiline comments instead of `/* */`.

#### Encoding

Write non-ASCII characters without escaping, except characters that are likely to confuse readers.

#### Numbers

Always add `.0` (e.g. `double x = 2.0 * pi`), and prefix with `0.` (e.g. double x = 0.001).
Digit grouping with `_` is optional; use it only for amounts or quantities, not identifiers.

### Naming

Follow [Google’s Java naming conventions](https://google.github.io/styleguide/javaguide.html#s5-naming).
Notably, treat acronyms as words – for example, `CobolError`, **not** `COBOLError`.
You may alter this practice if needed to maintain consistency with an extant convention;
in particular, for `IO` (e.g. in `IOException`).
Name asynchronous methods (those that return a `CompletableFuture`) with the suffix `Async`;
for example, `calculateAsync()`.

### Member ordering

!!! note

    I don’t recommend sorting members retroactively because it can result in large diffs.

!!! tip

    IntelliJ can do this for you.
    Import the [IntelliJ formatter settings](intellij-style.xml).
    To set manually, choose the default order and enable “keep getters and setters together”.

Sort members by the following rules.

1. `static final` field
2. initializer
3. field
4. constructor
5. `static` method
6. method
7. getter/setter
8. `equals`, `hashCode`, and `toString` (in order)
9. `enum`, `interface`, `static class`, `class` (in order)

Within each of the 10 types, always pair associated getters and setters (getter first),
and sort by decreasing visibility.
