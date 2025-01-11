# ISO 8601 problems

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

The two main standards for date-times and related concepts both have some issues.
[RFC 3339](https://datatracker.ietf.org/doc/rfc3339/)
a few problems.
[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)
has a **lot** of problems.

!!! related

    - [Duration specification](../spec/fixed-iso-8601.md)
    - [API conventions](../convention/apis.md#durations-and-intervals)

## ISO 8601

ISO 8601 is not just `YYYY-MM-DD'T'hh:mm:ss[.iiiiii]`.
It’s a long and complex document that prescribes notations for
dates, times, date-times, week-dates, durations, and intervals.

### Date-times

#### First, the good

Clarity, wide adoption, and lexicographical sorting.
A more minor feature is
[astronomical year numbering](https://en.wikipedia.org/wiki/Astronomical_year_numbering),
which simplifies calculations.
(A downside is that negative years are one off of CE/BCE (or AD/BC):
`0000-03-03` is in _1 BCE_; and `−0001-01-01` is in _2 BCE_.)

#### Representations are non-unique

Unique representations are great in software because they facilitate useful string comparisons.
You can index better, search more easily, etc., even without understanding the semantics.

Unfortunately, ISO 8601 dates, times, and date-times lack this property.
`"2024-12-16T14:30-08:00" != "2024-12-16T14:30−08:00"`.
But aren’t they the same date-times?

First, it allows `,` or `.` as the
[decimal seperator](https://en.wikipedia.org/wiki/Decimal_separator). †
Sadly, `"14:30:55.250" != "14:30:55,250"`.

<small>
<b>†</b>
`.` is preferred in international contexts.
See [_documentation: quantities_](../convention/documentation.md#quantities).
</small>

It allows `14:30:00.1`, `14:30:00.10`, and `14:30:00.100`,
even if the communicating parties agreed to use 3-digit precision.
It could have required that either 6, 9, or 27 digits are used.

It also allows `24:00:00`, where `2024-12-16T24:00` is `2024-12-17T00:00`.
Interestingly, `00:60:00` is not allowed.
However, `00:00:60` is – apparently this was to simplify working with leap-seconds.

For UTC offsets, it allows:
- either 4 or 2 digits (`+04:00` or `+04`)
- A minus sign (`−`) or a hyphen-minus (`-`) for negative offsets.
- The equivalent offsets `Z`, `+00`, `+00:00`, `±00`, and `±00:00`.
  Yep, you can use `±`.
  Ironically, it forbids `-00`, `-00`, `-00:00`, and `-00:00`.

#### UTC offsets are backward

I know we’re all used to it by now, but UTC offsets are clearly backward: They should be negated.
`2020-01-01T18:00-08:00` **should** mean $16 - 8 = 10$ UTC.
Instead, the actual hour is $16 + 8 = 24 \equiv 0$.
The syntax should be declarative – by specifying what the value **is**, not what operation was already performed.

#### The date and time aren’t visually seperated

It uses `T` to separate the date and time.
This is a bad, visually dense seperator.
`2020-01-01 18:35:55`, `2020-01-01_18:35:55`, `2020-01-01.18:35:55`, or even `2020-01-01@18:35:55`
would be much more readable.

#### It supports week-dates

An example [week-date](https://en.wikipedia.org/wiki/ISO_week_date): `2024-W51-1`.
This is an unnecessary definition, and it’s non-obvious.

### Durations

!!! related

    - [calculating durations](calculating-durations.md)
    - [API conventions](../convention/apis.md#durations-and-intervals)

Unfortunately, this duration format is already widespread: `P4M28DT19H42M15S`.
The syntax is (using spaces for clarity):

```text
'P' [n'Y'] [n'M'] [n'D'] [ 'T' [n'H'] [n'M'] [n'S'] ]
```

All values can have fractional components, so `P0.5Y` means half a year.
(`'P' n'W'` is also allowed.)

#### What the hell is a month?

What is it, and how many days does it have?
Years are also ambiguous:
It could be 365 days, a mean solar year (365.24217 solar days), or a specific solar year.

#### It’s hard to read

`P4M28DT19H42M15S` is very hard to read.
Instead, we could write `4 mo, 28 d, 19:22:15` using just 4 more characters.
Or (assuming 1 month = 30 days), `148 days, 19:42:15` using only 2 more characters.
Or `148d+19:42:15` for 3 fewer.

ISO 8601 does allow another format, but it’s not widespread:
`P0003-06-04T12:30:05`

#### It’s hard to parse and validate

Parsing, especially validating, takes some work.
This regex, which liberally uses lazy `??`, seems reasonable:

```regexp
P(?:(?P<years>\d+(?:[.,]\d++)?+)Y)??
P(?:(?P<months>\d+(?:[.,]\d++)?+)M)??
P(?:(?P<days>\d+(?:[.,]\d++)?+)D)??
(?:
T
P(?:(?P<hours>\d+(?:[.,]\d++)?+)H)??
P(?:(?P<minutes>\d+(?:[.,]\d++)?+)M)??
P(?:(?P<hours>\d+(?:[.,]\d++)?+)S)??
)?+
```

But, it allows some non-compliant and weird strings like `` (empty), `P0DT0H`, `P1Y13M` and `PT0.5H30M`.
This following regex is a little better:

```regexp
P
(?:(?P<years>\d*?[1-9](?:[.,]\d++)?+)Y)??
(?:(?P<months>(?:[1-9]|1[012])(?:[.,]\d++)?+)M)??
(?:(?P<days>(?:\d|[12]\d|3[01])(?:[.,]\d++)?+)D)??
(?:
T
(?:(?P<hours>(?:[1-9]|1[0-9]|2[0-3])(?:[.,]\d++)?+)H)??
(?:(?P<minutes>(?:[1-9]|[1-5][0-9])(?:[.,]\d++)?+)M)??
(?:(?P<seconds>(?:[1-9]|[1-5][0-9])(?:[.,]\d++)?+)S)??
)?+
```

But it (1) doesn’t allow leading 0s;
(2) requires _sec < 60_, _min < 60_, _hr < 24_, _day < 32_, and _month < 12; and
(3) allows (e.g.) February 31.
Compare with this pattern for `hh:mm:ss[.iiiiiiiii]`:

```regexp
(?P<hours>0\d|[1-9]\d++)
:
(?P<minutes>[0-5]\d)
:
(?P<seconds>[0-5]+\d)
\.
(?P<nanoseconds>\d{9})?+
```

#### Representations are non-unique

These are all equivalent:

- `PT0.5H` and `PT30M`
- `PT0.5H` and `PT0,5H`
- `P5D` and `P005D`
- `P0Y`, `P0M`, `P0D`, `PT0H`, `PT0M`, and `PT0S`

### Intervals

#### Representations are non-unique

Simple intervals can be written as either `start'/'end` or `start'/'duration`,
and `--` can be substituted for `/`.

#### Repeating intervals define the count oddly

The `n` in `Rn/` refers to the number of repeats, **not** the number of events.
Meaning, the number of **additional** events.
`R3/P1D` should mean once per day for 3 days; instead it means 4.
`R-1/P1D` means once per day, forever, which is unnecessarily unclear.
`R/P1D`, `R_/1D`, `R*/1D`, or `Rx/1D` would be much more intuitive.

## RFC 3339

ISO 8601 is a convoluted mess of excessive complexity, confusing syntax, and ambiguity.
RFC 3339 is much better but has a few problems,
and its introduction explains the problems with ISO 8601 it fixed.

### Problems with RFC 3339

Some of RFC 3339’s own problems are worth mentioning.

- `_` can be used instead of `T`.
  Although `_` makes date-times more readable, it makes equivalent date-times non-unique.
- `-00:00` considered a valid offset.
  (As is `Z`. Fortunately, in contrast to ISO 8601, `±00:00` is not).

### Lexicographical sorting

To sort date-times of the same UTC offset chronologically, you can sort their RFC 3339 timestamps lexicographically.
This obviously breaks if the offsets differ.
If you need both lexicographical sorting and the original offsets, see the next section.

??? note

    Even timestamps that share their YYYY-MM-DD and hh:mm:ss don’t sort well lexicographically:

    ```python
    assert "+01:00" < "-01:00"  # (recall: subtract offset to get the UTC instant)
    assert "-02:00" < "-01:00"  #
    assert "+02:00" < "+01:00"  # error – inverted
    assert "+01:00" < "Z"       #
    assert "Z"      < "-01:00"  # error
    ```

### Affixing timezone names

[RFC 9557](https://datatracker.ietf.org/doc/rfc9557/),
which updates RFC 3339, defines (among others) notation for attaching a timezone name to a date-time:

```text
2024-12-16T14:30:55-08:00[America/Los_Angeles]
```

The UTC offset is still required, even with the zone name.
The square brackets can contain an
[IANA zone name](https://data.iana.org/time-zones/tz-link.html),
but zone names like `Etc/GMT-8` are discouraged (except `Etc/UTC`).
You can also us offset; e.g. `[-08:00]`.

!!! note
   You cannot use both; `[-08:00][America/Los_Angeles]` is **invalid**.
   You could use a custom “experimental” key prefixed with `_`;
   e.g. `[-08:00][_tz=America/Los_Angeles]`.
   However, this requires agreement and would probably lead to confusion.

!!! note

    Prefixing `!`, as in `[!America/Los_Angeles]`, marks the zone/offset _critical_.
    However, many implementations will either ignore the marker or fail to parse the string.

#### Forcing natural lexicographical sorting

You can force natural lexicographical sorting while retaining the local offset or zone, either of these formats:

```text
2024-12-16T14:30:55Z[America/Los_Angeles]
2024-12-16T14:30:55Z[-08:00]
```

??? note

    These strings are considered _inconsistent_, and the prefix `!` forces implementations to treat them as erroneous:

    ```text
    2024-12-16T14:30:55+00:00[!-08:00]
    2024-12-16T14:30:55+00:00[!America/Los_Angeles]
    ```

    However, `2024-12-16T14:30:55Z[!-08:00]` is **not inconsistent**.
    Quoting from RFC 9557:

    > […] the IXDTF string:
    >
    > ```text
    > 2022-07-08T00:14:07Z[Europe/Paris]
    > ```
    >
    > does not exhibit such an inconsistency, [because] `Z` does not imply a specific preferred time zone […]

    However, `2024-12-16T14:30:55+00:00[!-08:00]` **is inconsistent**
    because RFC 3339 assigns `Z` and `+00:00` slightly different meanings.
    (Avoid `-00:00`.)
