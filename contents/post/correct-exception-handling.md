# Correct exception handling

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

<b>TL;DR:</b>

- Don’t catch exceptions at low levels.
- Catch, wrap, and rethrow when context is available.
- Define custom exception classes for specific types of failure (e.g. `MalformedConfigException`).
- Let exception classes generate messages from their fields.

## Let exceptions bubble up

People catch try to handle exceptions at the wrong level.
**Please, please let exceptions bubble up.**
They’re supposed to do that.

Use custom exception types along with the _catch-wrap-throw_ pattern.

But your `backUpFile(Path file)` method doesn’t know anything,
so let it throw an `IOException` or `UncheckedIOException`:
You absolutely do **not** need a `BackupFailedException`, at least not at that level.

Please, fellow programmers, stop trying to handle exceptions when they occur!
Just leave them be and let them bubble up.

## Wrap and rethrow

At a level where context is available, you should apply a catch-wrap-throw pattern.
Provide context by choosing a meaningful exception class, and via fields.

!!! example

    ```java
    public void update(AppNetworkClient client) {
        try {
            client.fetch(Mode.UDP, Constants.REMOTE_PATCH, version);
        } catch (UncheckedIOException e) { //(1)!
            throw new UpdateFailedException(version, e); //(2)!
        }
    }
    ```

    1. `UncheckedIOException` tends to be a good candidate to let bubble up pretty far.
    2. No message is needed because it can be generated.
       Specifically, let the exception class generate a message (as described below).

## Use and define custom exceptions

Exception classes in the Java Standard Library won’t cover all types of failure.
Define custom exceptions that differentiate between these types of failure,
which a reasonable caller may need to distinguish.
A caller may choose to re-attempt, work around, or fail gracefully.
Failing gracefully may be as simple as giving a user a useful message.

## Use an exception’s fields to generate a message

The message (ala `getMessage`) should be built from machine-readable fields, where possible.
This is more maintainable because messages are only generated in one place,
not everywhere the exception is constructed.
It also forces you to provide info in custom fields sufficient to understand the exception.

Apart from lazily initialized fields, exceptions should almost always be immutable.

<b>Two options:</b>

1. Build the message in the constructor and pass it to the superclass; or
2. Override `getMessage` (and `getLocalizedMessage`, if needed).

Use Option 2 only if building the message is slow – for example, if it performs analysis to identify the cause.

## Custom exception examples

=== "Option 1: the constructor builds the message"

    ```java
    public class QFormatParseException extends RuntimeException {

        // it's unfortunate that we can't make an Exception record;
        // this would be a lot shorter
        private final String line;
        private final int lineNumber;

        public QFormatParseException(@Nonnull String line, @Positive int lineNumber) {
            this(line, lineNumber, null);
        }

        public QFormatParseException(
            @Nonnull String line,
            @Positive int lineNumber,
            @Nullable Exception cause
        ) {
            // https://openjdk.org/jeps/465
            this(STR."Failed to parse line \{lineNumber}: '\{line}'.", cause);
            this.line = line;
            this.lineNumber = lineNumber;
        }

        @Override
        public int hashCode() {
            return Objects.hash(line, lineNumber);
        }

        @Override
        public boolean equals(Object other) {
            // https://openjdk.org/jeps/394
            if (other instanceOf QFormatParseException obj) {
                return line == obj.line && lineNumber == obj.lineNumber;
            }
            // multiversal equality for safety
            throw new IllegalArgumentException(
                STR."Cannot compare to \{obj.getClass().getName()}."
           );
        }

    }
    ```

=== "Option 2: `getMessage` builds the message lazily"

    ```java
    public class QFormatParseException extends RuntimeException {

        // it's unfortunate that we can't make an Exception record;
        // this would be a lot shorter
        private final String line;
        private final int lineNumber;
        private SyntaxTree syntaxTree;

        public QFormatParseException(@Nonnull String line, @Positive int lineNumber) {
            this(line, lineNumber, null);
        }

        public QFormatParseException(
            @Nonnull String line,
            @Positive int lineNumber,
            @Nullable Exception cause
        ) {
            // https://openjdk.org/jeps/465
            this(cause);
            this.line = line;
            this.lineNumber = lineNumber;
        }

        @Override
        public int hashCode() {
            return Objects.hash(line, lineNumber);
        }

        @Override
        @Nonnull
        public String getMessage() {
            // https://openjdk.org/jeps/465
            return STR."""
            Failed to parse line \{lineNumber}: '\{line}'.
            Reason: \{syntaxTree.errorSummary()}
            """
        }

        @Override
        public boolean equals(Object other) {
            // https://openjdk.org/jeps/394
            if (other instanceOf QFormatParseException obj) {
                return line == obj.line && lineNumber == obj.lineNumber;
            }
            // multiversal equality for safety
            throw new IllegalArgumentException(STR."Cannot compare to \{obj.getClass().getName()}.");
        }

        @Nonnull
        public SyntaxTree syntaxTree() {
            if (syntaxTree == null) {
                syntaxTree = new QFormatSyntaxTreeSimpleFactory().generate(line);
            }
            return syntaxTree;
        }

    }
    ```

## Case study: loading saved games

A `GameSaves.load(String name)` method should probably differentiate between these situations:

- No saved game matching `name` exists.
- Failed to find a necessary game resource.
- The saved game is invalid/corrupted.
- An IO problem occurred (e.g. no read privileges).

Because our hypothetical `GameSaves` class loads game resources as well as the game file,
a `FileNotFoundException` is not sufficient:
A reasonable caller may want to (and probably should) show the player a different error message.

- Save file not found:
  ```text
  No saved game with that name (level2.sav) exists in your saved games folder.
  Make sure you specified the correct name.
  ```
- Save file not readable:
  ```text
  Could not access your saved game (level2.sav).
  Please check the logs for details and troubleshooting.
  ```
- Save file malformatted:
  ```text
  Your saved game (level2.sav) is incorrectly formatted.
  It may be corrupted.
  ```
- Game resource missing:
  ```text
  Failed to find the resource file level-2-map.dat.
  You may need to re-install the game.
  ```
